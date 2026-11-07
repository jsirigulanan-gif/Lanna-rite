class_name LockedDoor3D
extends StaticBody3D

## Puzzle-locked door in 3D separating the wooden schoolhouse and the village shrine.
## Opens the Tung direction puzzle when interacted with while locked.

signal door_unlocked()
signal door_opened()

@export var door_name: String = "ประตูลานศาลผี (Lanna Shrine Door)"
@export var is_locked: bool = true
@export var puzzle_node_path: NodePath = ""

var _player_nearby: PlayerSibling3D = null
var _puzzle_ref: TungPuzzle = null

@onready var collision_shape: CollisionShape3D = get_node_or_null("CollisionShape3D")
@onready var interact_area: Area3D = get_node_or_null("InteractArea")
@onready var prompt_label: Label3D = get_node_or_null("PromptLabel3D")
@onready var door_mesh: MeshInstance3D = get_node_or_null("Visual/DoorMesh")
@onready var talisman_mesh: MeshInstance3D = get_node_or_null("Visual/TalismanMesh")

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2 | 4

	if not puzzle_node_path.is_empty():
		_puzzle_ref = get_node_or_null(puzzle_node_path) as TungPuzzle
	else:
		_puzzle_ref = get_tree().root.find_child("TungPuzzle", true, false) as TungPuzzle

	if _puzzle_ref != null:
		_puzzle_ref.puzzle_solved.connect(unlock_door)

	if interact_area != null:
		interact_area.body_entered.connect(_on_interact_area_entered)
		interact_area.body_exited.connect(_on_interact_area_exited)

	_update_visuals()
	if prompt_label != null:
		prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _player_nearby != null:
		if (InputMap.has_action("interact") and event.is_action_pressed("interact")) or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E):
			interact()

func _on_interact_area_entered(body: Node3D) -> void:
	if body is PlayerSibling3D:
		_player_nearby = body
		if prompt_label != null:
			if is_locked:
				prompt_label.text = "[E] สำรวจประตูปิดผนึกยันต์ตุง"
			else:
				prompt_label.text = "ประตูเปิดแล้ว"
			prompt_label.visible = true

func _on_interact_area_exited(body: Node3D) -> void:
	if body == _player_nearby:
		_player_nearby = null
		if prompt_label != null:
			prompt_label.visible = false

func interact() -> void:
	if is_locked:
		if _puzzle_ref != null:
			_puzzle_ref.open_puzzle()
	else:
		open_door()

func unlock_door() -> void:
	if not is_locked:
		return
	is_locked = false
	door_unlocked.emit()
	open_door()

func open_door() -> void:
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)
	if door_mesh != null:
		# Swing door open by 90 degrees
		var tween: Tween = create_tween()
		tween.tween_property(door_mesh, "rotation:y", deg_to_rad(90.0), 1.2)
	if talisman_mesh != null:
		talisman_mesh.visible = false
	if prompt_label != null:
		prompt_label.text = "ประตูเปิดแล้ว"
	door_opened.emit()

func _update_visuals() -> void:
	if talisman_mesh != null:
		talisman_mesh.visible = is_locked
