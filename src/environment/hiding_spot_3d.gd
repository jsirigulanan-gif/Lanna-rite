class_name HidingSpot3D
extends Area3D

## 3D Hiding spot (teak wooden locker / school cabinet) for Shadow of Lanna: Midnight Rite.
## Allows players to hide from spirits, dropping chase aggro and muting footsteps.

signal player_entered_hiding(sibling: PlayerSibling3D)
signal player_exited_hiding(sibling: PlayerSibling3D)

@export var spot_name: String = "ตู้เก็บของไม้สักเก่า"

var _player_nearby: PlayerSibling3D = null
var _hidden_sibling: PlayerSibling3D = null

@onready var prompt_label: Label3D = get_node_or_null("PromptLabel3D")
@onready var locker_door: MeshInstance3D = get_node_or_null("Visual/LockerDoorMesh")

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player sibling
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

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerSibling3D and _hidden_sibling == null:
		_player_nearby = body as PlayerSibling3D
		if prompt_label != null:
			prompt_label.text = "[E] ซ่อนตัวใน" + spot_name
			prompt_label.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body == _player_nearby:
		_player_nearby = null
		if prompt_label != null and _hidden_sibling == null:
			prompt_label.visible = false

func enter_spot(sibling: PlayerSibling3D) -> void:
	if sibling == null:
		return

	_hidden_sibling = sibling
	_player_nearby = null
	sibling.enter_hiding(global_position)

	if prompt_label != null:
		prompt_label.text = "[E] ออกจากตู้ซ่อน"
		prompt_label.visible = true

	# Animate locker door closing
	if locker_door != null:
		var tween: Tween = create_tween()
		tween.tween_property(locker_door, "rotation:y", 0.0, 0.4)

	player_entered_hiding.emit(sibling)

func exit_spot() -> void:
	if _hidden_sibling == null:
		return

	var exit_pos: Vector3 = global_position + (transform.basis.z * 1.2)
	var exited_sibling: PlayerSibling3D = _hidden_sibling
	_hidden_sibling = null

	exited_sibling.exit_hiding(exit_pos)

	if prompt_label != null:
		prompt_label.text = "[E] ซ่อนตัวใน" + spot_name
		prompt_label.visible = false

	# Animate locker door opening
	if locker_door != null:
		var tween: Tween = create_tween()
		tween.tween_property(locker_door, "rotation:y", deg_to_rad(65.0), 0.4)

	player_exited_hiding.emit(exited_sibling)
