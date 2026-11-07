class_name PlayerSibling
extends CharacterBody2D

## Player Sibling Controller for Shadow of Lanna: Midnight Rite.
## Controls individual sibling movement, stamina, running, and follow-AI behaviour.

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
@export var walk_speed: float = 120.0
@export var run_speed: float = 210.0
@export var max_stamina: float = 100.0
@export var stamina_drain_rate: float = 25.0
@export var stamina_recovery_rate: float = 18.0
@export var follow_distance: float = 70.0
@export var stop_distance: float = 40.0
@export var max_health: int = 100
@export var use_tank_controls: bool = true ## Classic Resident Evil 1-3 tank controls
@export var turn_speed: float = 3.6 ## Radians per second
@export var back_speed_multiplier: float = 0.55 ## Slower backwards speed

var current_stamina: float = 100.0
var current_health: int = 100
var is_active_player: bool = false
var is_hidden: bool = false
var current_state: State = State.IDLE
var facing_direction: Vector2 = Vector2.DOWN
var target_to_follow: Node2D = null

@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var visual_node: Node2D = get_node_or_null("Visual")
@onready var lantern: Node2D = get_node_or_null("LanternLight")

func _ready() -> void:
	add_to_group("player")
	current_stamina = max_stamina
	current_health = max_health
	stamina_changed.emit(current_stamina, max_stamina)
	health_changed.emit(current_health, max_health)

func _physics_process(delta: float) -> void:
	if is_hidden:
		velocity = Vector2.ZERO
		return

	if is_active_player:
		_process_active_input(delta)
	else:
		_process_follow_ai(delta)

	move_and_slide()

## Handles player movement input and stamina management when this sibling is active.
func _process_active_input(delta: float) -> void:
	var wants_to_run: bool = (InputMap.has_action("run") and Input.is_action_pressed("run")) or Input.is_key_pressed(KEY_SHIFT)

	if use_tank_controls:
		_process_tank_controls(delta, wants_to_run)
	else:
		_process_modern_controls(delta, wants_to_run)

## Classic Resident Evil 1-3 tank controls (Rotate with Left/Right, Move Forward/Back).
func _process_tank_controls(delta: float, wants_to_run: bool) -> void:
	var turn_input: float = Input.get_axis("ui_left", "ui_right")
	var move_input: float = -Input.get_axis("ui_up", "ui_down") # Up = +1 (Forward), Down = -1 (Backward)

	if absf(turn_input) > 0.01:
		facing_direction = facing_direction.rotated(turn_input * turn_speed * delta).normalized()

	if visual_node != null:
		visual_node.rotation = facing_direction.angle() + (PI * 0.5)

	if absf(move_input) > 0.01:
		var speed: float = walk_speed
		if move_input > 0.0:
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

		velocity = facing_direction * (move_input * speed)
	else:
		current_state = State.IDLE
		velocity = Vector2.ZERO
		_recover_stamina(delta)

## Modern 8-directional control scheme.
func _process_modern_controls(delta: float, wants_to_run: bool) -> void:
	var input_vector: Vector2 = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	var is_moving: bool = input_vector.length_squared() > 0.001

	if is_moving:
		input_vector = input_vector.normalized()
		facing_direction = input_vector
		if visual_node != null:
			visual_node.rotation = facing_direction.angle() + (PI * 0.5)

		if wants_to_run and current_stamina > 0.0:
			current_state = State.RUN
			velocity = input_vector * run_speed
			current_stamina = maxf(0.0, current_stamina - (stamina_drain_rate * delta))
			stamina_changed.emit(current_stamina, max_stamina)
		else:
			current_state = State.WALK
			velocity = input_vector * walk_speed
			_recover_stamina(delta * 0.5)
	else:
		current_state = State.IDLE
		velocity = Vector2.ZERO
		_recover_stamina(delta)

## Handles companion follow behavior when inactive.
func _process_follow_ai(delta: float) -> void:
	_recover_stamina(delta)

	if target_to_follow == null:
		velocity = Vector2.ZERO
		current_state = State.IDLE
		return

	var to_target: Vector2 = target_to_follow.global_position - global_position
	var distance: float = to_target.length()

	if distance > follow_distance:
		current_state = State.FOLLOW
		var dir: Vector2 = to_target.normalized()
		facing_direction = dir

		# Sprint to catch up if fallen far behind
		var speed: float = run_speed if distance > follow_distance * 1.8 else walk_speed
		velocity = dir * speed
	elif distance <= stop_distance:
		current_state = State.IDLE
		velocity = Vector2.ZERO
	else:
		# Gradually slow down in buffer zone
		var t: float = (distance - stop_distance) / (follow_distance - stop_distance)
		velocity = to_target.normalized() * (walk_speed * t)

func _recover_stamina(delta: float) -> void:
	if current_stamina < max_stamina:
		current_stamina = minf(max_stamina, current_stamina + (stamina_recovery_rate * delta))
		stamina_changed.emit(current_stamina, max_stamina)

## Sets whether this sibling is the directly controlled character.
func set_active(active: bool, new_target_to_follow: Node2D = null) -> void:
	is_active_player = active
	target_to_follow = new_target_to_follow
	velocity = Vector2.ZERO
	current_state = State.IDLE
	active_state_changed.emit(is_active_player)

## Deals damage to this sibling.
func take_damage(amount: int) -> void:
	current_health = maxi(0, current_health - amount)
	health_changed.emit(current_health, max_health)

## Restores health.
func heal(amount: int) -> void:
	current_health = mini(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

## Hides this sibling in a locker or under a desk.
func enter_hiding(hiding_pos: Vector2) -> void:
	is_hidden = true
	global_position = hiding_pos
	velocity = Vector2.ZERO
	visible = false
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)

## Exits the hiding spot.
func exit_hiding(exit_pos: Vector2) -> void:
	is_hidden = false
	global_position = exit_pos
	visible = true
	if collision_shape != null:
		collision_shape.set_deferred("disabled", false)

