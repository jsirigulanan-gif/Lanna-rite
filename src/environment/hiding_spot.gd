class_name HidingSpot
extends Area2D

## Hiding spot (wooden locker or school desk) for Shadow of Lanna: Midnight Rite.
## Allows players to hide from spirits, dropping chase aggro and muting sound.

signal player_entered_hiding(sibling: PlayerSibling)
signal player_exited_hiding(sibling: PlayerSibling)

@export var spot_name: String = "ตู้เก็บของไม้เก่า"

var _player_nearby: PlayerSibling = null
var _hidden_sibling: PlayerSibling = null

@onready var prompt_label: Label = get_node_or_null("PromptLabel")
@onready var visual_rect: ColorRect = get_node_or_null("Visual/ColorRect")

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player layer
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label != null:
		prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if (InputMap.has_action("interact") and event.is_action_pressed("interact")) or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E):
		if _hidden_sibling != null:
			exit_spot()
		elif _player_nearby != null:
			enter_spot(_player_nearby)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerSibling and _hidden_sibling == null:
		_player_nearby = body as PlayerSibling
		if prompt_label != null:
			prompt_label.text = "[E] ซ่อนตัวใน" + spot_name
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body == _player_nearby:
		_player_nearby = null
		if prompt_label != null and _hidden_sibling == null:
			prompt_label.visible = false

## Enters this hiding spot.
func enter_spot(sibling: PlayerSibling) -> void:
	if sibling == null:
		return

	_hidden_sibling = sibling
	_player_nearby = null
	sibling.enter_hiding(global_position)

	if prompt_label != null:
		prompt_label.text = "[E] ออกจากที่ซ่อน"
		prompt_label.visible = true

	if visual_rect != null:
		visual_rect.color = Color(0.4, 0.25, 0.15, 1.0) # Closed wooden shade

	var audio: AudioManager = get_tree().root.find_child("AudioManager", true, false) as AudioManager
	if audio != null:
		audio.play_creak_sound()

	player_entered_hiding.emit(sibling)

## Exits this hiding spot.
func exit_spot() -> void:
	if _hidden_sibling == null:
		return

	var sibling: PlayerSibling = _hidden_sibling
	_hidden_sibling = null
	sibling.exit_hiding(global_position + Vector2(0.0, 24.0))

	if prompt_label != null:
		prompt_label.visible = false

	if visual_rect != null:
		visual_rect.color = Color(0.55, 0.35, 0.2, 1.0) # Regular wooden locker

	var audio: AudioManager = get_tree().root.find_child("AudioManager", true, false) as AudioManager
	if audio != null:
		audio.play_creak_sound()

	player_exited_hiding.emit(sibling)
