class_name GameManager
extends Node

## Core game state loop controller for Shadow of Lanna: Midnight Rite.
## Monitors player life, altar cleansing, game over fail states, and victory conditions.

signal game_state_changed(new_state: GameState)
signal altar_extinguished()
signal game_won()
signal game_lost(reason: String)

enum GameState {
	PLAYING,
	GAME_OVER,
	VICTORY,
}

var current_state: GameState = GameState.PLAYING
var is_altar_cleansed: bool = false

@export var game_over_screen_path: NodePath = ""
@export var victory_screen_path: NodePath = ""

var _game_over_screen: GameOverScreen = null
var _victory_screen: VictoryScreen = null

func _ready() -> void:
	current_state = GameState.PLAYING

	if not game_over_screen_path.is_empty():
		_game_over_screen = get_node_or_null(game_over_screen_path) as GameOverScreen
	else:
		_game_over_screen = get_tree().root.find_child("GameOverScreen", true, false) as GameOverScreen

	if not victory_screen_path.is_empty():
		_victory_screen = get_node_or_null(victory_screen_path) as VictoryScreen
	else:
		_victory_screen = get_tree().root.find_child("VictoryScreen", true, false) as VictoryScreen

	# Hook up sibling health monitors
	_connect_sibling_listeners()

func _connect_sibling_listeners() -> void:
	var potential_players: Array[Node] = get_tree().get_nodes_in_group("player")
	if potential_players.is_empty():
		var scene_root: Node = get_tree().current_scene if get_tree().current_scene != null else get_parent()
		if scene_root != null:
			for child in scene_root.find_children("*", "PlayerSibling", true, false):
				potential_players.append(child)
			for child in scene_root.find_children("*", "PlayerSibling3D", true, false):
				potential_players.append(child)

	for p in potential_players:
		if p.has_signal("health_changed"):
			var char_name: String = p.character_name if "character_name" in p else "ตัวละคร"
			p.health_changed.connect(func(curr: int, _max: int):
				if curr <= 0 and current_state == GameState.PLAYING:
					trigger_game_over(char_name + " สิ้นลมหายใจท่ามกลางหมอกอาถรรพ์")
			)

## Cleanses the village sacrificial altar.
func cleanse_altar() -> void:
	if is_altar_cleansed:
		return
	is_altar_cleansed = true
	altar_extinguished.emit()

## Triggers victory when siblings pass the village escape gate after cleansing the altar.
func trigger_victory() -> void:
	if current_state != GameState.PLAYING:
		return
	current_state = GameState.VICTORY
	game_state_changed.emit(current_state)
	game_won.emit()

	if _victory_screen != null:
		_victory_screen.show_screen()

## Triggers defeat when a sibling falls.
func trigger_game_over(reason: String = "ถูกวิญญาณร้ายจู่โจม") -> void:
	if current_state != GameState.PLAYING:
		return
	current_state = GameState.GAME_OVER
	game_state_changed.emit(current_state)
	game_lost.emit(reason)

	if _game_over_screen != null:
		_game_over_screen.show_screen(reason)

## Restarts the game level.
func restart_game() -> void:
	get_tree().reload_current_scene()
