class_name LockedDoor
extends StaticBody2D

## Puzzle-locked door separating the wooden schoolhouse and the village shrine.
## Opens the Tung direction puzzle when interacted with while locked.

signal door_unlocked()
signal door_opened()

@export var door_name: String = "ประตูลานศาลผี"
@export var is_locked: bool = true
@export var puzzle_node_path: NodePath = ""

var _player_nearby: PlayerSibling = null
var _puzzle_ref: TungPuzzle = null

@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var interact_area: Area2D = get_node_or_null("InteractArea")
@onready var prompt_label: Label = get_node_or_null("PromptLabel")
@onready var door_visual: ColorRect = get_node_or_null("Visual/ColorRect")

func _ready() -> void:
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

func _on_interact_area_entered(body: Node2D) -> void:
	if body is PlayerSibling:
		_player_nearby = body
		if prompt_label != null:
			if is_locked:
				prompt_label.text = "[E] สำรวจประตูล็อกยันต์ตุง"
			else:
				prompt_label.text = "[E] เปิดประตูสู่ลานศาลผี"
			prompt_label.visible = true

func _on_interact_area_exited(body: Node2D) -> void:
	if body == _player_nearby:
		_player_nearby = null
		if prompt_label != null:
			prompt_label.visible = false

## Interacts with the door.
func interact() -> void:
	if is_locked:
		if _puzzle_ref != null:
			_puzzle_ref.open_puzzle()
		elif prompt_label != null:
			prompt_label.text = "ประตูล็อกแน่นหนาด้วยอาคมตุงล้านนา"
	else:
		open_door()

## Unlocks the talisman seal.
func unlock_door() -> void:
	is_locked = false
	door_unlocked.emit()
	_update_visuals()
	if prompt_label != null:
		prompt_label.text = "กลอนอาคมคลายตัวแล้ว! กด [E] เพื่อเปิด"

## Opens the door and allows physical passage.
func open_door() -> void:
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)
	if door_visual != null:
		door_visual.color = Color(0.2, 0.6, 0.3, 0.4) # Open green/faded doorway
	if prompt_label != null:
		prompt_label.visible = false
	door_opened.emit()

func _update_visuals() -> void:
	if door_visual != null:
		if is_locked:
			door_visual.color = Color(0.65, 0.2, 0.15, 1.0) # Crimson ward locked
		else:
			door_visual.color = Color(0.4, 0.7, 0.4, 1.0) # Unlocked ready to pass
