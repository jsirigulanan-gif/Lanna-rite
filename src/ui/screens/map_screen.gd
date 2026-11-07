class_name MapScreen
extends CanvasLayer

## Classic Resident Evil / Silent Hill style Map System for Shadow of Lanna: Midnight Rite.
## Displays architectural blueprint of the schoolhouse and shrine courtyard with real-time player position.

signal map_toggled(is_open: bool)

@onready var control_root: Control = get_node_or_null("Control")
@onready var player_marker: Control = get_node_or_null("Control/Panel/MapContainer/PlayerMarker")
@onready var door_status_label: Label = get_node_or_null("Control/Panel/LegendBox/DoorStatusLabel")
@onready var altar_status_label: Label = get_node_or_null("Control/Panel/LegendBox/AltarStatusLabel")

# Map world bounds for mapping real position to minimap UI
# World X: 0 to 800 -> Map UI X: 40 to 360 (Width: 320)
# World Y: 0 to 240 -> Map UI Y: 40 to 180 (Height: 140)
const WORLD_MIN_X: float = 0.0
const WORLD_MAX_X: float = 800.0
const WORLD_MIN_Y: float = 0.0
const WORLD_MAX_Y: float = 240.0

const MAP_UI_X: float = 40.0
const MAP_UI_Y: float = 40.0
const MAP_UI_WIDTH: float = 320.0
const MAP_UI_HEIGHT: float = 140.0

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	if control_root != null:
		control_root.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M):
		toggle_map()
	elif control_root != null and control_root.visible:
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE):
			close_map()

## Toggles map display on/off.
func toggle_map() -> void:
	if control_root == null:
		return
	var new_state: bool = not control_root.visible
	control_root.visible = new_state
	get_tree().paused = new_state
	if new_state:
		_update_map_markers()
	map_toggled.emit(new_state)

func close_map() -> void:
	if control_root != null:
		control_root.visible = false
	get_tree().paused = false
	map_toggled.emit(false)

func _process(_delta: float) -> void:
	if control_root != null and control_root.visible:
		_update_map_markers()

func _update_map_markers() -> void:
	# 1. Update player position marker (2D or 3D)
	var mgr_3d: Node = get_tree().root.find_child("SiblingManager3D", true, false)
	var mgr_2d: Node = get_tree().root.find_child("SiblingManager", true, false)
	var mgr: Node = mgr_3d if mgr_3d != null else mgr_2d

	if mgr != null and mgr.has_method("get_active_sibling") and mgr.get_active_sibling() != null and player_marker != null:
		var sibling: Node = mgr.get_active_sibling()
		var norm_x: float = 0.5
		var norm_y: float = 0.5
		if sibling is Node3D:
			# 3D: X from 0.0 to 42.0, Z from -7.0 to 11.0
			norm_x = clampf(sibling.global_position.x / 42.0, 0.0, 1.0)
			norm_y = clampf((sibling.global_position.z + 7.0) / 18.0, 0.0, 1.0)
		elif sibling is Node2D:
			norm_x = clampf((sibling.global_position.x - WORLD_MIN_X) / (WORLD_MAX_X - WORLD_MIN_X), 0.0, 1.0)
			norm_y = clampf((sibling.global_position.y - WORLD_MIN_Y) / (WORLD_MAX_Y - WORLD_MIN_Y), 0.0, 1.0)

		player_marker.position = Vector2(
			MAP_UI_X + (norm_x * MAP_UI_WIDTH),
			MAP_UI_Y + (norm_y * MAP_UI_HEIGHT)
		)

	# 2. Update locked door status (2D or 3D)
	var door_3d: Node = get_tree().root.find_child("LockedDoor3D", true, false)
	var door_2d: Node = get_tree().root.find_child("LockedDoor", true, false)
	var door: Node = door_3d if door_3d != null else door_2d
	if door != null and door_status_label != null:
		var is_locked: bool = door.is_locked if "is_locked" in door else false
		if is_locked:
			door_status_label.text = "ประตูลานศาลผี: [ ลงอาคมล็อก ]"
			door_status_label.modulate = Color(0.95, 0.3, 0.3, 1.0)
		else:
			door_status_label.text = "ประตูลานศาลผี: [ ปลดล็อกแล้ว ]"
			door_status_label.modulate = Color(0.3, 0.9, 0.4, 1.0)

	# 3. Update altar status
	var gm: GameManager = get_tree().root.find_child("GameManager", true, false) as GameManager
	if gm != null and altar_status_label != null:
		if gm.is_altar_cleansed:
			altar_status_label.text = "แท่นบูชา: [ ไฟดับมอดแล้ว ]"
			altar_status_label.modulate = Color(0.3, 0.9, 0.4, 1.0)
		else:
			altar_status_label.text = "แท่นบูชา: [ ไฟพิธีกรรมลุกโชน ]"
			altar_status_label.modulate = Color(1.0, 0.6, 0.2, 1.0)
