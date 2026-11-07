class_name SpiritAI3D
extends CharacterBody3D

## 3D Spirit Enemy AI for Shadow of Lanna: Midnight Rite.
## Implements Lanna ghostly entity (Phi Ka / Phi Phong) 3D perception,
## floating patrol, hearing running footsteps, chase, attack, and stun.

signal state_changed(new_state: State, old_state: State)
signal target_spotted(target: Node3D)
signal attack_landed(target: Node3D, damage: int)

enum State {
	PATROL,
	INVESTIGATE,
	CHASE,
	ATTACK,
}

@export var ghost_name: String = "ผีกะ (Phi Ka)"
@export var patrol_speed: float = 2.0
@export var investigate_speed: float = 2.8
@export var chase_speed: float = 4.6

@export var vision_range: float = 14.0
@export var vision_cone_deg: float = 90.0
@export var light_detection_multiplier: float = 1.6
@export var hearing_range_running: float = 15.0

@export var attack_range: float = 1.8
@export var attack_damage: int = 25
@export var attack_cooldown: float = 1.5
@export var search_duration: float = 4.0

@export var patrol_points: Array[Vector3] = []

var current_state: State = State.PATROL
var current_target: PlayerSibling3D = null
var last_known_position: Vector3 = Vector3.ZERO
var _patrol_index: int = 0
var _can_attack: bool = true
var _search_timer: float = 0.0
var _attack_timer: float = 0.0
var is_stunned: bool = false
var _stun_timer: float = 0.0
var _bob_timer: float = 0.0

@onready var raycast: RayCast3D = get_node_or_null("RayCast3D")
@onready var visual: Node3D = get_node_or_null("Visual")
@onready var aura_light: OmniLight3D = get_node_or_null("AuraLight3D")

func _ready() -> void:
	add_to_group("enemies")
	# Collision Layer 3 (mask 4)
	collision_layer = 4
	collision_mask = 1 | 2 # World & Player

	if patrol_points.is_empty():
		patrol_points.append(global_position)
		patrol_points.append(global_position + Vector3(6.0, 0, 0))
		patrol_points.append(global_position + Vector3(6.0, 0, 4.0))
		patrol_points.append(global_position + Vector3(0, 0, 4.0))

func _physics_process(delta: float) -> void:
	_bob_timer += delta * 3.5
	if visual != null:
		visual.position.y = 0.8 + sin(_bob_timer) * 0.12

	if is_stunned:
		_stun_timer -= delta
		velocity = velocity.move_toward(Vector3.ZERO, 10.0 * delta)
		move_and_slide()
		if _stun_timer <= 0.0:
			is_stunned = false
			_switch_state(State.INVESTIGATE)
		return

	_update_timers(delta)
	_sense_environment()

	match current_state:
		State.PATROL:
			_process_patrol(delta)
		State.INVESTIGATE:
			_process_investigate(delta)
		State.CHASE:
			_process_chase(delta)
		State.ATTACK:
			_process_attack(delta)

	move_and_slide()

func _update_timers(delta: float) -> void:
	if not _can_attack:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_can_attack = true

	if current_state == State.INVESTIGATE:
		_search_timer -= delta
		if _search_timer <= 0.0:
			_switch_state(State.PATROL)

## Scans the scene for player sightings and footstep sounds.
func _sense_environment() -> void:
	var potential_players: Array[Node] = get_tree().get_nodes_in_group("player")
	var detected_player: PlayerSibling3D = null
	var closest_dist_sq: float = INF

	for node in potential_players:
		var sibling: PlayerSibling3D = node as PlayerSibling3D
		if sibling == null or sibling.is_hidden:
			continue

		var diff: Vector3 = sibling.global_position - global_position
		var flat_diff: Vector3 = Vector3(diff.x, 0, diff.z)
		var dist: float = flat_diff.length()

		# 1. Vision Check (Modified by lantern light)
		var effective_vision: float = vision_range
		if sibling.lantern is LanternLight3D:
			var lantern_ref: LanternLight3D = sibling.lantern as LanternLight3D
			if lantern_ref.is_lit and lantern_ref.current_fuel > 0.0:
				effective_vision *= light_detection_multiplier

		var in_vision_range: bool = dist <= effective_vision
		var in_fov: bool = true
		var forward: Vector3 = -transform.basis.z.normalized()
		if flat_diff.length_squared() > 0.01:
			var to_dir: Vector3 = flat_diff.normalized()
			var dot: float = forward.dot(to_dir)
			var angle_deg: float = rad_to_deg(acos(clampf(dot, -1.0, 1.0)))
			in_fov = angle_deg <= (vision_cone_deg * 0.5)

		var has_los: bool = false
		if in_vision_range and in_fov:
			has_los = _check_line_of_sight(sibling.global_position)

		if has_los:
			var dist_sq: float = dist * dist
			if dist_sq < closest_dist_sq:
				closest_dist_sq = dist_sq
				detected_player = sibling

		# 2. Hearing Check (Player running nearby)
		if detected_player == null and sibling.current_state == PlayerSibling3D.State.RUN:
			if dist <= hearing_range_running:
				if current_state != State.CHASE:
					last_known_position = sibling.global_position
					_search_timer = search_duration
					_switch_state(State.INVESTIGATE)

	if detected_player != null:
		current_target = detected_player
		last_known_position = detected_player.global_position
		target_spotted.emit(detected_player)

		var diff: Vector3 = current_target.global_position - global_position
		var flat_dist: float = Vector3(diff.x, 0, diff.z).length()
		if flat_dist <= attack_range and _can_attack:
			_switch_state(State.ATTACK)
		else:
			_switch_state(State.CHASE)
	elif current_state == State.CHASE:
		current_target = null
		_search_timer = search_duration
		_switch_state(State.INVESTIGATE)

func _check_line_of_sight(target_pos: Vector3) -> bool:
	if raycast == null:
		return true

	raycast.global_position = global_position + Vector3(0, 1.0, 0)
	raycast.target_position = target_pos - raycast.global_position
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var col: Object = raycast.get_collider()
		if col is PlayerSibling3D:
			return true
		return false
	return true

func _process_patrol(delta: float) -> void:
	if patrol_points.is_empty():
		velocity.x = 0.0
		velocity.z = 0.0
		return

	var target_pt: Vector3 = patrol_points[_patrol_index]
	var diff: Vector3 = target_pt - global_position
	var flat_diff: Vector3 = Vector3(diff.x, 0, diff.z)

	if flat_diff.length() < 0.6:
		_patrol_index = (_patrol_index + 1) % patrol_points.size()
		velocity.x = 0.0
		velocity.z = 0.0
	else:
		var dir: Vector3 = flat_diff.normalized()
		_orient_towards(dir, delta * 3.0)
		velocity.x = dir.x * patrol_speed
		velocity.z = dir.z * patrol_speed

func _process_investigate(delta: float) -> void:
	var diff: Vector3 = last_known_position - global_position
	var flat_diff: Vector3 = Vector3(diff.x, 0, diff.z)

	if flat_diff.length() < 0.8:
		# Rotate around searching
		rotate_y(delta * 2.0)
		velocity.x = 0.0
		velocity.z = 0.0
	else:
		var dir: Vector3 = flat_diff.normalized()
		_orient_towards(dir, delta * 4.0)
		velocity.x = dir.x * investigate_speed
		velocity.z = dir.z * investigate_speed

func _process_chase(delta: float) -> void:
	if current_target == null:
		_switch_state(State.INVESTIGATE)
		return

	var diff: Vector3 = current_target.global_position - global_position
	var flat_diff: Vector3 = Vector3(diff.x, 0, diff.z)
	var dir: Vector3 = flat_diff.normalized()

	_orient_towards(dir, delta * 6.0)
	velocity.x = dir.x * chase_speed
	velocity.z = dir.z * chase_speed

func _process_attack(delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0

	if current_target != null:
		var diff: Vector3 = current_target.global_position - global_position
		var flat_diff: Vector3 = Vector3(diff.x, 0, diff.z)
		_orient_towards(flat_diff.normalized(), delta * 8.0)

		if flat_diff.length() <= attack_range and _can_attack:
			_can_attack = false
			_attack_timer = attack_cooldown
			current_target.take_damage(attack_damage)
			attack_landed.emit(current_target, attack_damage)

			var audio_mgr = get_node_or_null("/root/AudioManager")
			if audio_mgr != null and audio_mgr.has_method("play_jumpscare_sting"):
				audio_mgr.play_jumpscare_sting()

	_switch_state(State.CHASE)

func _orient_towards(direction: Vector3, weight: float) -> void:
	if direction.length_squared() < 0.001:
		return
	var target_angle: float = atan2(-direction.x, -direction.z)
	rotation.y = lerp_angle(rotation.y, target_angle, weight)

func _switch_state(new_state: State) -> void:
	if current_state == new_state:
		return
	var old_state: State = current_state
	current_state = new_state
	state_changed.emit(new_state, old_state)

	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr != null and audio_mgr.has_method("set_chase_state"):
		audio_mgr.set_chase_state(current_state == State.CHASE)

func stun(duration: float = 3.0) -> void:
	is_stunned = true
	_stun_timer = duration
	current_target = null
