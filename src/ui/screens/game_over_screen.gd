class_name GameOverScreen
extends CanvasLayer

## Game Over screen for Shadow of Lanna: Midnight Rite.
## Retro survival horror fail screen with retry and quit options.

@onready var reason_label: Label = get_node_or_null("Control/Panel/ReasonLabel")
@onready var control_root: Control = get_node_or_null("Control")

func _ready() -> void:
	if control_root != null:
		control_root.visible = false

## Shows game over overlay with a contextual failure reason.
func show_screen(reason: String = "") -> void:
	if control_root != null:
		control_root.visible = true
	if reason_label != null and not reason.is_empty():
		reason_label.text = reason

func retry() -> void:
	get_tree().reload_current_scene()

func quit_game() -> void:
	get_tree().quit()
