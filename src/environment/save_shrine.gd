class_name SaveShrine
extends Area2D

## Classic Resident Evil Typewriter style Save Station for Shadow of Lanna: Midnight Rite.
## Allows players to record their survival progress (health, inventory, lantern fuel, puzzle states).

signal game_saved()

@export var shrine_name: String = "ศาลพระภูมิเรือนไม้ (จุดบันทึกเกม)"

var _player_nearby: PlayerSibling = null
var _save_file_path: String = "user://savegame.json"

@onready var prompt_label: Label = get_node_or_null("PromptLabel")
@onready var candle_light: PointLight2D = get_node_or_null("PointLight2D")

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player layer
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label != null:
		prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _player_nearby != null:
		if (InputMap.has_action("interact") and event.is_action_pressed("interact")) or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E):
			save_game()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerSibling:
		_player_nearby = body as PlayerSibling
		if prompt_label != null:
			prompt_label.text = "[E] บันทึกความทรงจำ (เซฟเกม)"
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body == _player_nearby:
		_player_nearby = null
		if prompt_label != null:
			prompt_label.visible = false

## Saves game state to user storage.
func save_game() -> void:
	var save_data := {}

	# Sibling data
	var mgr: SiblingManager = get_tree().root.find_child("SiblingManager", true, false) as SiblingManager
	if mgr != null and mgr.get_active_sibling() != null:
		var active: PlayerSibling = mgr.get_active_sibling()
		save_data["active_sibling"] = active.character_name
		save_data["player_x"] = active.global_position.x
		save_data["player_y"] = active.global_position.y
		save_data["health"] = active.current_health

	# Lantern data
	var lanterns: Array[Node] = get_tree().get_nodes_in_group("lantern")
	for l in lanterns:
		var lantern_ref: LanternLight = l as LanternLight
		if lantern_ref != null:
			save_data["lantern_fuel"] = lantern_ref.current_fuel

	# Game state
	var gm: GameManager = get_tree().root.find_child("GameManager", true, false) as GameManager
	if gm != null:
		save_data["altar_cleansed"] = gm.is_altar_cleansed

	# Write JSON
	var file := FileAccess.open(_save_file_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()

	# Audio chime
	var audio: AudioManager = get_tree().root.find_child("AudioManager", true, false) as AudioManager
	if audio != null:
		audio.play_pickup_sound()

	if prompt_label != null:
		prompt_label.text = "บันทึกความคืบหน้าของสองพี่น้องเรียบร้อยแล้ว!"
		get_tree().create_timer(3.0).timeout.connect(func():
			if prompt_label != null and _player_nearby != null:
				prompt_label.text = "[E] บันทึกความทรงจำ (เซฟเกม)"
		)

	game_saved.emit()
