class_name SpiritAI
extends CharacterBody2D

## Spirit Enemy AI for Shadow of Lanna: Midnight Rite.
## Implements Lanna ghostly entity (Phi Ka / Phi Phong) perception, patrol, investigation, chase, and attack behaviors.

signal state_changed(new_state: State, old_state: State)
signal target_spotted(target: Node2D)
signal attack_landed(target: Node2D, damage: int)

enum State {
	PATROL,
	INVESTIGATE,
	CHASE,
	ATTACK,
}

@export var ghost_name: String = "ผีกะ"
@export var patrol_speed: float = 70.0
@export var investigate_speed: float = 90.0
@export var chase_speed: float = 145.0

@export var vision_range: float = 220.0
@export var vision_cone_deg: float = 90.0
@export var light_detection_multiplier: float = 1.7
@export var hearing_range_running: float = 260.0

@export var attack_range: float = 42.0
@export var attack_damage: int = 25
@export var attack_cooldown: float = 1.6
@export var knockback_force: float = 240.0
@export var search_duration: float = 4.0

@export var patrol_points: Array[Vector2] = []

var current_state: State = State.PATROL
var current_target: PlayerSibling = null
var last_known_position: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.DOWN
var _patrol_index: int = 0
var _can_attack: bool = true
var _search_timer: float = 0.0
var _attack_timer: float = 0.0
var is_stunned: bool = false
var _stun_timer: float = 0.0

@onready var raycast: RayCast2D = get_node_or_null("RayCast2D")
@onready var visual: Node2D = get_node_or_null("Visual")

func _ready() -> void:
	add_to_group("enemies")
	if patrol_points.is_empty():
		patrol_points.append(global_position)
		patrol_points.append(global_position + Vector2(100.0, 0.0))
		patrol_points.append(global_position + Vector2(100.0, 80.0))
		patrol_points.append(global_position + Vector2(0.0, 80.0))

func _physics_process(delta: float) -> void:
	if is_stunned:
		_stun_timer -= delta
		velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
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
	if potential_players.is_empty():
		# Fallback: search for PlayerSibling instances in parent tree if group is unset
		var tree_root: Node = get_tree().current_scene if get_tree().current_scene != null else get_parent()
		if tree_root != null:
			for child in tree_root.find_children("*", "PlayerSibling", true, false):
				potential_players.append(child)

	var detected_player: PlayerSibling = null
	var closest_dist_sq: float = INF

	for node in potential_players:
		var sibling: PlayerSibling = node as PlayerSibling
		if sibling == null or sibling.is_hidden:
			continue

		var to_sibling: Vector2 = sibling.global_position - global_position
		var dist: float = to_sibling.length()

		# 1. Vision Check (Modified by lantern light)
		var effective_vision: float = vision_range
		var is_lantern_active: bool = false
		if sibling.lantern is LanternLight:
			var lantern_ref: LanternLight = sibling.lantern as LanternLight
			if lantern_ref.is_lit and lantern_ref.current_fuel > 0.0:
				is_lantern_active = true
				effective_vision *= light_detection_multiplier

		var in_vision_range: bool = dist <= effective_vision
		var in_fov: bool = true
		if facing_direction.length_squared() > 0.01:
			var angle_to_target: float = rad_to_deg(absf(facing_direction.angle_to(to_sibling)))
			in_fov = angle_to_target <= (vision_cone_deg * 0.5)

		# Check line of sight with RayCast2D
		var has_los: bool = false
		if in_vision_range and in_fov:
			has_los = _check_line_of_sight(sibling.global_position)

		if has_los:
			var dist_sq: float = dist * dist
			if dist_sq < closest_dist_sq:
				closest_dist_sq = dist_sq
				detected_player = sibling

		# 2. Hearing Check (Player running nearby)
		if detected_player == null and sibling.current_state == PlayerSibling.State.RUN:
			if dist <= hearing_range_running:
				if current_state != State.CHASE:
					last_known_position = sibling.global_position
					_search_timer = search_duration
					_switch_state(State.INVESTIGATE)

	if detected_player != null:
		current_target = detected_player
		last_known_position = detected_player.global_position
		target_spotted.emit(detected_player)

		var to_target: Vector2 = current_target.global_position - global_position
		if to_target.length() <= attack_range and _can_attack:
			_switch_state(State.ATTACK)
		else:
			_switch_state(State.CHASE)
	elif current_state == State.CHASE:
		# Lost sight of player while chasing -> switch to investigating last known point
		current_target = null
		_search_timer = search_duration
		_switch_state(State.INVESTIGATE)

func _check_line_of_sight(target_pos: Vector2) -> bool:
	if raycast == null:
		return true

	raycast.global_position = global_position
	raycast.target_position = target_pos - global_position
	raycast.force_raycast_update()

	# If raycast hit something, check if it hit wall/obstacle before reaching target
	if raycast.is_colliding():
		var col: Object = raycast.get_collider()
		if col is PlayerSibling:
			return true
		return false
	return true

func _process_patrol(_delta: float) -> void:
	if patrol_points.is_empty():
		velocity = Vector2.ZERO
		return

	var target_pt: Vector2 = patrol_points[_patrol_index]
	var to_pt: Vector2 = target_pt - global_position

	if to_pt.length() <= 12.0:
		_patrol_index = (_patrol_index + 1) % patrol_points.size()
		target_pt = patrol_points[_patrol_index]
		to_pt = target_pt - global_position

	var dir: Vector2 = to_pt.normalized()
	facing_direction = dir
	velocity = dir * patrol_speed

func _process_investigate(_delta: float) -> void:
	var to_loc: Vector2 = last_known_position - global_position

	if to_loc.length() > 16.0:
		var dir: Vector2 = to_loc.normalized()
		facing_direction = dir
		velocity = dir * investigate_speed
	else:
		# Wander / scan around search location
		velocity = Vector2(-facing_direction.y, facing_direction.x) * (patrol_speed * 0.4)

func _process_chase(_delta: float) -> void:
	if current_target == null:
		_switch_state(State.INVESTIGATE)
		return

	var to_target: Vector2 = current_target.global_position - global_position
	var dist: float = to_target.length()

	if dist <= attack_range and _can_attack:
		_switch_state(State.ATTACK)
		return

	var dir: Vector2 = to_target.normalized()
	facing_direction = dir
	velocity = dir * chase_speed

func _process_attack(_delta: float) -> void:
	velocity = Vector2.ZERO

	if current_target != null and _can_attack:
		_can_attack = false
		_attack_timer = attack_cooldown

		# Deal damage
		current_target.take_damage(attack_damage)

		# Apply knockback away from spirit
		var knockback_dir: Vector2 = (current_target.global_position - global_position).normalized()
		if knockback_dir.length_squared() < 0.01:
			knockback_dir = facing_direction
		current_target.velocity = knockback_dir * knockback_force

		attack_landed.emit(current_target, attack_damage)

	# Transition back to chase or investigate after initiating attack
	if current_target != null:
		_switch_state(State.CHASE)
	else:
		_switch_state(State.INVESTIGATE)

func _switch_state(new_state: State) -> void:
	if current_state == new_state:
		return
	var old_state: State = current_state
	current_state = new_state
	state_changed.emit(new_state, old_state)

## Applies holy thread ward stun and knockback.
func apply_stun(duration: float, knockback_vector: Vector2) -> void:
	is_stunned = true
	_stun_timer = duration
	velocity = knockback_vector
	current_target = null
	_switch_state(State.INVESTIGATE)

