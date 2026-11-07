class_name PlayerSibling3D
extends CharacterBody3D

## 3D Player Sibling Controller for Shadow of Lanna: Midnight Rite.
## Implements classic Resident Evil 1-3 3D Tank Controls, companion follow AI,
## stamina, health, and 3D dynamic lantern lighting.

signal stamina_changed(current: float, max_stamina: float)
signal active_state_changed(is_active: bool)
signal health_changed(current_health: int, max_health: int)

enum SiblingRole {
	BROTHER,
	SISTER,
}

enum State {
	IDLE,
	WALK,
	RUN,
	FOLLOW,
}

@export var sibling_role: SiblingRole = SiblingRole.BROTHER
@export var character_name: String = "พี่ชาย"
@export var walk_speed: float = 3.6 ## Meters/sec
@export var run_speed: float = 6.4 ## Meters/sec
@export var turn_speed: float = 4.5 ## Radians/sec
@export var back_speed_multiplier: float = 0.5
@export var max_stamina: float = 100.0
@export var stamina_drain_rate: float = 24.0
@export var stamina_recovery_rate: float = 18.0
@export var follow_distance: float = 2.2
@export var stop_distance: float = 1.2
@export var max_health: int = 100
@export var use_tank_controls: bool = false ## Default to easy direct/screen-space controls

var current_stamina: float = 100.0
var current_health: int = 100
var is_active_player: bool = false
var is_hidden: bool = false
var current_state: State = State.IDLE
var target_to_follow: Node3D = null
var gravity: float = 9.8

var _footstep_timer: float = 0.0

@onready var visual_mesh: Node3D = get_node_or_null("Visual")
@onready var collision_shape: CollisionShape3D = get_node_or_null("CollisionShape3D")
@onready var lantern: Node3D = get_node_or_null("LanternLight3D")

func _ready() -> void:
	add_to_group("player")
	# Collision Layer 2: Player
	collision_layer = 2
	collision_mask = 1 | 4 # 1: World, 4: Enemies/Props
	current_stamina = max_stamina
	current_health = max_health
	stamina_changed.emit(current_stamina, max_stamina)
	health_changed.emit(current_health, max_health)

func _physics_process(delta: float) -> void:
	# Safety anti-fall check: never fall into void
	if global_position.y < -1.2:
		global_position.y = 0.1
		velocity = Vector3.ZERO

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if is_hidden:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	if is_active_player:
		_process_active_input(delta)
	else:
		_process_follow_ai(delta)

	move_and_slide()

	# Audio footsteps during movement
	if (current_state == State.WALK or current_state == State.RUN) and is_on_floor():
		_footstep_timer += delta
		var step_interval: float = 0.32 if current_state == State.RUN else 0.55
		if _footstep_timer >= step_interval:
			_footstep_timer = 0.0
			var audio_mgr = get_node_or_null("/root/AudioManager")
			if audio_mgr != null and audio_mgr.has_method("play_footstep"):
				audio_mgr.play_footstep()

## Handles player movement input and stamina management when this sibling is active.
func _process_active_input(delta: float) -> void:
	var wants_to_run: bool = (InputMap.has_action("run") and Input.is_action_pressed("run")) or Input.is_key_pressed(KEY_SHIFT)

	if use_tank_controls:
		_process_tank_controls(delta, wants_to_run)
	else:
		_process_direct_controls(delta, wants_to_run)

## Classic Resident Evil 1-3 3D tank controls (A/D turns body, W moves forward, S backwards).
func _process_tank_controls(delta: float, wants_to_run: bool) -> void:
	var turn_input: float = 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT) or (InputMap.has_action("ui_left") and Input.is_action_pressed("ui_left")):
		turn_input += 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT) or (InputMap.has_action("ui_right") and Input.is_action_pressed("ui_right")):
		turn_input -= 1.0

	var move_input: float = 0.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP) or (InputMap.has_action("ui_up") and Input.is_action_pressed("ui_up")):
		move_input += 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN) or (InputMap.has_action("ui_down") and Input.is_action_pressed("ui_down")):
		move_input -= 1.0

	if absf(turn_input) > 0.01:
		rotate_y(turn_input * turn_speed * delta)

	if absf(move_input) > 0.01:
		var speed: float = walk_speed
		if move_input > 0.0:
			# Moving forward
			if wants_to_run and current_stamina > 0.0:
				current_state = State.RUN
				speed = run_speed
				current_stamina = maxf(0.0, current_stamina - (stamina_drain_rate * delta))
				stamina_changed.emit(current_stamina, max_stamina)
			else:
				current_state = State.WALK
				_recover_stamina(delta * 0.5)
		else:
			# Walking backwards
			current_state = State.WALK
			speed = walk_speed * back_speed_multiplier
			_recover_stamina(delta * 0.5)

		# Forward in Godot 3D is -transform.basis.z
		var forward_dir: Vector3 = -transform.basis.z.normalized()
		var move_vector: Vector3 = forward_dir * (move_input * speed)
		velocity.x = move_vector.x
		velocity.z = move_vector.z
	else:
		current_state = State.IDLE
		velocity.x = 0.0
		velocity.z = 0.0
		_recover_stamina(delta)

## Modern Camera-Relative 8-directional control scheme (easy intuitive movement).
## W = moves away from camera into the screen, S = moves towards camera,
## A = moves left on screen, D = moves right on screen.
func _process_direct_controls(delta: float, wants_to_run: bool) -> void:
	var raw_vec: Vector2 = _get_raw_input_vector()
	var is_moving: bool = raw_vec.length_squared() > 0.01

	if is_moving:
		var input_vec: Vector2 = raw_vec.normalized()
		var move_dir: Vector3 = Vector3.ZERO
		var cam: Camera3D = get_viewport().get_camera_3d()

		if cam != null:
			var cam_basis: Basis = cam.global_transform.basis
			var forward: Vector3 = -cam_basis.z
			forward.y = 0.0
			forward = forward.normalized()

			var right: Vector3 = cam_basis.x
			right.y = 0.0
			right = right.normalized()

			# Up (-Y) moves forward into screen, Down (+Y) moves back towards camera
			move_dir = (right * input_vec.x + forward * (-input_vec.y)).normalized()
		else:
			move_dir = Vector3(input_vec.x, 0.0, input_vec.y).normalized()

		if move_dir.length_squared() > 0.001:
			var target_angle: float = atan2(-move_dir.x, -move_dir.z)
			rotation.y = lerp_angle(rotation.y, target_angle, turn_speed * delta * 2.8)

		var speed: float = walk_speed
		if wants_to_run and current_stamina > 0.0:
			current_state = State.RUN
			speed = run_speed
			current_stamina = maxf(0.0, current_stamina - (stamina_drain_rate * delta))
			stamina_changed.emit(current_stamina, max_stamina)
		else:
			current_state = State.WALK
			_recover_stamina(delta * 0.5)

		velocity.x = move_dir.x * speed
		velocity.z = move_dir.z * speed
	else:
		current_state = State.IDLE
		velocity.x = 0.0
		velocity.z = 0.0
		_recover_stamina(delta)

## Reads directional input supporting W, A, S, D, Arrow keys, and standard actions.
func _get_raw_input_vector() -> Vector2:
	var x: float = 0.0
	var y: float = 0.0

	# Left
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT) or (InputMap.has_action("ui_left") and Input.is_action_pressed("ui_left")):
		x -= 1.0
	# Right
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT) or (InputMap.has_action("ui_right") and Input.is_action_pressed("ui_right")):
		x += 1.0
	# Up / Forward
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP) or (InputMap.has_action("ui_up") and Input.is_action_pressed("ui_up")):
		y -= 1.0
	# Down / Backward
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN) or (InputMap.has_action("ui_down") and Input.is_action_pressed("ui_down")):
		y += 1.0

	return Vector2(x, y)

## Handles companion follow behavior when inactive.
func _process_follow_ai(delta: float) -> void:
	_recover_stamina(delta)

	if target_to_follow == null:
		velocity.x = 0.0
		velocity.z = 0.0
		current_state = State.IDLE
		return

	var diff: Vector3 = target_to_follow.global_position - global_position
	var flat_diff: Vector3 = Vector3(diff.x, 0, diff.z)
	var distance: float = flat_diff.length()

	if distance > follow_distance:
		current_state = State.FOLLOW
		var dir: Vector3 = flat_diff.normalized()

		# Smoothly rotate towards leader
		var target_angle: float = atan2(-dir.x, -dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, turn_speed * delta * 1.5)

		var speed: float = run_speed if distance > follow_distance * 1.8 else walk_speed
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
	elif distance <= stop_distance:
		current_state = State.IDLE
		velocity.x = 0.0
		velocity.z = 0.0
	else:
		current_state = State.IDLE
		velocity.x = 0.0
		velocity.z = 0.0

func _recover_stamina(delta: float) -> void:
	if current_stamina < max_stamina:
		current_stamina = minf(max_stamina, current_stamina + (stamina_recovery_rate * delta))
		stamina_changed.emit(current_stamina, max_stamina)

func set_active(active: bool, new_target_to_follow: Node3D = null) -> void:
	is_active_player = active
	target_to_follow = new_target_to_follow
	velocity.x = 0.0
	velocity.z = 0.0
	current_state = State.IDLE
	active_state_changed.emit(is_active_player)

func take_damage(amount: int) -> void:
	current_health = maxi(0, current_health - amount)
	health_changed.emit(current_health, max_health)

func heal(amount: int) -> void:
	current_health = mini(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

## Hides this sibling in a 3D locker or cupboard.
func enter_hiding(hiding_pos: Vector3) -> void:
	is_hidden = true
	global_position = hiding_pos
	velocity = Vector3.ZERO
	visible = false
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)

## Exits the 3D hiding spot.
func exit_hiding(exit_pos: Vector3) -> void:
	is_hidden = false
	global_position = exit_pos
	visible = true
	if collision_shape != null:
		collision_shape.set_deferred("disabled", false)
