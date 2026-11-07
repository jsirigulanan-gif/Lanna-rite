class_name SiblingManager
extends Node2D

## Coordinates the brother and sister character pairing.
## Handles character switching, shared camera framing, and active/inactive state propagation.

signal character_switched(active_sibling: PlayerSibling, inactive_sibling: PlayerSibling)

@export var brother_path: NodePath = "Brother"
@export var sister_path: NodePath = "Sister"
@export var camera_path: NodePath = "Camera2D"
@export var switch_cooldown: float = 0.3
@export var use_fixed_cameras: bool = true

var brother: PlayerSibling = null
var sister: PlayerSibling = null
var camera: Camera2D = null

var active_sibling: PlayerSibling = null
var _last_switch_time: float = 0.0

func _ready() -> void:
	brother = get_node_or_null(brother_path) as PlayerSibling
	sister = get_node_or_null(sister_path) as PlayerSibling
	camera = get_node_or_null(camera_path) as Camera2D

	# Default to brother as initial controlled player
	if brother != null and sister != null:
		set_active_sibling(brother)
	elif brother != null:
		set_active_sibling(brother)
	elif sister != null:
		set_active_sibling(sister)

func _unhandled_input(event: InputEvent) -> void:
	# Check for switch character button (Tab or custom action)
	if (InputMap.has_action("switch_character") and event.is_action_pressed("switch_character")) or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB):
		var current_time: float = float(Time.get_ticks_msec()) / 1000.0
		if current_time - _last_switch_time >= switch_cooldown:
			_last_switch_time = current_time
			toggle_active_sibling()

## Toggles between brother and sister.
func toggle_active_sibling() -> void:
	if brother == null or sister == null:
		return

	if active_sibling == brother:
		set_active_sibling(sister)
	else:
		set_active_sibling(brother)

## Sets the specific sibling as active and assigns the other to follow.
func set_active_sibling(target_sibling: PlayerSibling) -> void:
	if target_sibling == null:
		return

	active_sibling = target_sibling

	if brother != null and sister != null:
		if active_sibling == brother:
			brother.set_active(true, null)
			sister.set_active(false, brother)
			character_switched.emit(brother, sister)
		else:
			sister.set_active(true, null)
			brother.set_active(false, sister)
			character_switched.emit(sister, brother)

	_update_camera_target()

func _update_camera_target() -> void:
	if use_fixed_cameras:
		return

	if camera != null and active_sibling != null:
		if camera.get_parent() != active_sibling:
			camera.reparent(active_sibling)
			camera.position = Vector2.ZERO

## Returns the sibling currently controlled by the player.
func get_active_sibling() -> PlayerSibling:
	return active_sibling

## Returns the companion sibling currently following.
func get_inactive_sibling() -> PlayerSibling:
	if active_sibling == brother:
		return sister
	return brother
