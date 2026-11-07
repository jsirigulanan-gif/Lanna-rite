class_name SiblingManager3D
extends Node3D

## Coordinates the brother and sister character pairing in 3D.
## Handles character switching (Tab key) and companion follow targeting.

signal character_switched(active_sibling: PlayerSibling3D, inactive_sibling: PlayerSibling3D)

@export var brother_path: NodePath = "Brother"
@export var sister_path: NodePath = "Sister"
@export var switch_cooldown: float = 0.3

var brother: PlayerSibling3D = null
var sister: PlayerSibling3D = null
var active_sibling: PlayerSibling3D = null
var _last_switch_time: float = 0.0

func _ready() -> void:
	brother = get_node_or_null(brother_path) as PlayerSibling3D
	sister = get_node_or_null(sister_path) as PlayerSibling3D

	# Default to brother as initial controlled player
	if brother != null and sister != null:
		set_active_sibling(brother)
	elif brother != null:
		set_active_sibling(brother)
	elif sister != null:
		set_active_sibling(sister)

func _unhandled_input(event: InputEvent) -> void:
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
func set_active_sibling(target_sibling: PlayerSibling3D) -> void:
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

## Returns the sibling currently controlled by the player.
func get_active_sibling() -> PlayerSibling3D:
	return active_sibling

## Returns the companion sibling currently following.
func get_inactive_sibling() -> PlayerSibling3D:
	if active_sibling == brother:
		return sister
	return brother
