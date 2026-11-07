class_name MainLevel3D
extends Node3D

## Master 3D Level for Shadow of Lanna: Midnight Rite.
## Implements classic Resident Evil 1-3 Fixed CCTV Camera gameplay,
## dynamic 3D lighting, 3D sibling duo, spirit AI, and atmospheric Thai horror.

@onready var game_manager: GameManager = $GameManager
@onready var escape_gate: Area3D = $Environment/EscapeGate
@onready var escape_label: Label3D = $Environment/EscapeGate/PromptLabel3D

func _ready() -> void:
	_setup_input_map()
	if escape_gate != null:
		escape_gate.body_entered.connect(_on_escape_gate_body_entered)
	if escape_label != null:
		escape_label.visible = false

## Registers WASD and other essential controls to Godot's InputMap globally.
func _setup_input_map() -> void:
	_bind_key("ui_up", KEY_W)
	_bind_key("ui_down", KEY_S)
	_bind_key("ui_left", KEY_A)
	_bind_key("ui_right", KEY_D)
	_bind_key("interact", KEY_E)
	_bind_key("run", KEY_SHIFT)
	_bind_key("switch_character", KEY_TAB)
	_bind_key("toggle_inventory", KEY_I)
	_bind_key("toggle_map", KEY_M)

func _bind_key(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var ev := InputEventKey.new()
	ev.physical_keycode = keycode
	ev.keycode = keycode
	if not InputMap.action_has_event(action, ev):
		InputMap.action_add_event(action, ev)

func _on_escape_gate_body_entered(body: Node3D) -> void:
	if body is PlayerSibling3D:
		if game_manager != null and game_manager.is_altar_cleansed:
			game_manager.trigger_victory()
		elif escape_label != null:
			escape_label.text = "ประตูรั้วลงอาคมหนาแน่น! ต้องไปดับไฟที่แท่นบูชายัญก่อน!"
			escape_label.visible = true
			get_tree().create_timer(3.5).timeout.connect(func():
				if escape_label != null:
					escape_label.visible = false
			)
