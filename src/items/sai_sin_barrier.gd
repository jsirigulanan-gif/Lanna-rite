class_name SaiSinBarrier
extends Area2D

## Holy thread ward (Sai Sin) barrier for Shadow of Lanna: Midnight Rite.
## Strung across doorways to repel spirits, stunning them for 5 seconds upon contact.

signal ward_triggered(spirit: Node2D)
signal ward_broken()

@export var stun_duration: float = 5.0
@export var knockback_force: float = 280.0
@export var durability: int = 1

var _is_triggered: bool = false

@onready var visual_line: Line2D = get_node_or_null("Line2D")

func _ready() -> void:
	collision_layer = 0
	collision_mask = 4 # Enemy layer
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _is_triggered:
		return

	if body is SpiritAI or body.is_in_group("enemies"):
		_trigger_ward(body)

func _trigger_ward(enemy: Node2D) -> void:
	_is_triggered = true

	var knockback_dir: Vector2 = (enemy.global_position - global_position).normalized()
	if knockback_dir.length_squared() < 0.01:
		knockback_dir = Vector2.UP

	var knockback_vector: Vector2 = knockback_dir * knockback_force

	if enemy.has_method("apply_stun"):
		enemy.apply_stun(stun_duration, knockback_vector)

	ward_triggered.emit(enemy)
	durability -= 1

	if durability <= 0:
		ward_broken.emit()
		# Flash and dissolve ward line
		if visual_line != null:
			visual_line.default_color = Color(1.0, 0.9, 0.4, 0.4)
		get_tree().create_timer(0.3).timeout.connect(queue_free)
