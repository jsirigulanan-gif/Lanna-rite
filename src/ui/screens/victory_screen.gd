class_name VictoryScreen
extends CanvasLayer

## Victory / Escape screen for Shadow of Lanna: Midnight Rite.
## Appears when siblings successfully cleanse the altar and escape before dawn.

@onready var control_root: Control = get_node_or_null("Control")

func _ready() -> void:
	if control_root != null:
		control_root.visible = false

## Shows victory screen overlay.
func show_screen() -> void:
	if control_root != null:
		control_root.visible = true

func play_again() -> void:
	get_tree().reload_current_scene()

func quit_game() -> void:
	get_tree().quit()
