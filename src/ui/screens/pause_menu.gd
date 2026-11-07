class_name PauseMenu
extends CanvasLayer

## Retro survival horror pause & options menu for Shadow of Lanna: Midnight Rite.
## Toggles pause state with ESC, allows switching between Tank Controls and Modern Controls.

signal resumed()

@onready var control_root: Control = get_node_or_null("Control")
@onready var controls_toggle_button: Button = get_node_or_null("Control/Panel/VBoxContainer/ControlsButton")

var _is_tank_controls: bool = false

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	if control_root != null:
		control_root.visible = false
	_update_controls_button_text()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE):
		toggle_pause()

## Toggles pause menu and engine time scale.
func toggle_pause() -> void:
	var new_paused: bool = not get_tree().paused
	get_tree().paused = new_paused
	if control_root != null:
		control_root.visible = new_paused
	if not new_paused:
		resumed.emit()

func resume_game() -> void:
	get_tree().paused = false
	if control_root != null:
		control_root.visible = false
	resumed.emit()

## Toggles between Tank Controls and Modern 8-Way Controls on all player siblings.
func toggle_controls_mode() -> void:
	_is_tank_controls = not _is_tank_controls
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	for p in players:
		if "use_tank_controls" in p:
			p.use_tank_controls = _is_tank_controls

	_update_controls_button_text()

func _update_controls_button_text() -> void:
	if controls_toggle_button != null:
		if _is_tank_controls:
			controls_toggle_button.text = "การควบคุม: Tank Controls (สไตล์ RE1-3)"
		else:
			controls_toggle_button.text = "การควบคุม: Modern 8-Way (อิสระ 8 ทิศ)"

func restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func quit_to_desktop() -> void:
	get_tree().quit()
