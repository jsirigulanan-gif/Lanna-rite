class_name LanternLight3D
extends Node3D

## Lantern & dynamic 3D lighting controller for Shadow of Lanna: Midnight Rite.
## Uses real-time OmniLight3D and SpotLight3D with shadow casting for dramatic horror atmosphere.

signal fuel_changed(current_fuel: float, max_fuel: float)
signal fuel_depleted()

@export var max_fuel: float = 100.0
@export var burn_rate: float = 1.2 ## Fuel consumed per second while lit
@export var normal_energy: float = 1.8
@export var dim_energy: float = 0.4
@export var normal_range: float = 9.0
@export var dim_range: float = 3.5
@export var flicker_intensity: float = 0.08

## Focus mode settings (Alan Wake style beam stun)
@export var focus_drain_multiplier: float = 3.0
@export var focus_energy_multiplier: float = 2.2
@export var focus_range_multiplier: float = 1.6
@export var normal_spot_angle: float = 48.0
@export var focus_spot_angle: float = 22.0

var current_fuel: float = 100.0
var is_lit: bool = true
var is_focused: bool = false
var _flicker_timer: float = 0.0
var _current_spot_angle: float = 48.0

@onready var omni_light: OmniLight3D = get_node_or_null("OmniLight3D")
@onready var spot_light: SpotLight3D = get_node_or_null("SpotLight3D")

func _ready() -> void:
	add_to_group("lantern")
	current_fuel = max_fuel
	_current_spot_angle = normal_spot_angle
	if spot_light != null:
		spot_light.spot_angle = normal_spot_angle
	fuel_changed.emit(current_fuel, max_fuel)
	_update_light_appearance()

func _process(delta: float) -> void:
	if not is_lit:
		if omni_light != null:
			omni_light.visible = false
		if spot_light != null:
			spot_light.visible = false
		return

	if omni_light != null:
		omni_light.visible = true
	if spot_light != null:
		spot_light.visible = true

	# Check player input for focus mode (RMB or F key)
	_process_focus_input()

	var effective_burn_rate: float = burn_rate * (focus_drain_multiplier if is_focused else 1.0)

	if current_fuel > 0.0:
		current_fuel = maxf(0.0, current_fuel - (effective_burn_rate * delta))
		fuel_changed.emit(current_fuel, max_fuel)
		if current_fuel <= 0.0:
			is_focused = false
			fuel_depleted.emit()

	_flicker_timer += delta * 12.0
	var flicker: float = sin(_flicker_timer) * flicker_intensity + sin(_flicker_timer * 2.3) * (flicker_intensity * 0.5)

	var base_energy: float = dim_energy if current_fuel <= 0.0 else normal_energy
	var base_range: float = dim_range if current_fuel <= 0.0 else normal_range

	var target_energy: float = base_energy * (focus_energy_multiplier if is_focused else 1.0)
	var target_range: float = base_range * (focus_range_multiplier if is_focused else 1.0)
	var target_angle: float = focus_spot_angle if is_focused else normal_spot_angle

	_current_spot_angle = lerpf(_current_spot_angle, target_angle, delta * 10.0)

	if omni_light != null:
		omni_light.light_energy = maxf(0.05, (base_energy * 0.8) + flicker)
		omni_light.omni_range = base_range
	if spot_light != null:
		spot_light.light_energy = maxf(0.05, target_energy + flicker)
		spot_light.spot_range = target_range
		spot_light.spot_angle = _current_spot_angle

	if is_focused and current_fuel > 0.0:
		_check_and_stun_enemies(target_range)

func _process_focus_input() -> void:
	var parent_sibling = get_parent() as PlayerSibling3D
	var is_controlled: bool = (parent_sibling != null and parent_sibling.is_active_player)

	var wants_focus: bool = false
	if is_controlled and current_fuel > 0.0:
		wants_focus = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or Input.is_key_pressed(KEY_F)

	if wants_focus and not is_focused:
		is_focused = true
		var audio_mgr = get_node_or_null("/root/AudioManager")
		if audio_mgr != null and audio_mgr.has_method("play_focus_flare"):
			audio_mgr.play_focus_flare()
	elif not wants_focus and is_focused:
		is_focused = false

func _check_and_stun_enemies(max_dist: float) -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return

	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var origin: Vector3 = global_position
	# In Godot 3D, forward is -basis.z
	var forward: Vector3 = -global_transform.basis.z.normalized()

	for node in enemies:
		var enemy = node as Node3D
		if enemy == null or not is_instance_valid(enemy):
			continue

		var enemy_pos: Vector3 = enemy.global_position + Vector3(0, 0.8, 0)
		var to_enemy: Vector3 = enemy_pos - origin
		var dist: float = to_enemy.length()

		if dist > max_dist or dist < 0.1:
			continue

		var dir_to_enemy: Vector3 = to_enemy.normalized()
		var dot: float = forward.dot(dir_to_enemy)
		var angle_deg: float = rad_to_deg(acos(clampf(dot, -1.0, 1.0)))

		# Check if within spot cone angle
		if angle_deg <= (_current_spot_angle * 0.9):
			# Raycast to verify direct line of sight (not behind walls)
			var query := PhysicsRayQueryParameters3D.create(origin, enemy_pos)
			query.collision_mask = 1 # World collision layer
			var result = space_state.intersect_ray(query)

			# If nothing obstructed or hit point is beyond enemy
			if result.is_empty():
				if enemy.has_method("stun"):
					enemy.stun(3.0)

func _update_light_appearance() -> void:
	var target_energy: float = dim_energy if current_fuel <= 0.0 else normal_energy
	var target_range: float = dim_range if current_fuel <= 0.0 else normal_range
	if omni_light != null:
		omni_light.light_energy = target_energy
		omni_light.omni_range = target_range
	if spot_light != null:
		spot_light.light_energy = target_energy * 1.4
		spot_light.spot_range = target_range * 1.5

func add_fuel(amount: float) -> void:
	current_fuel = minf(max_fuel, current_fuel + amount)
	fuel_changed.emit(current_fuel, max_fuel)

func toggle_light() -> void:
	is_lit = not is_lit
