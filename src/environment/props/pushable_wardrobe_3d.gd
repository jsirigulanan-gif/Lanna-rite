class_name PushableWardrobe3D
extends StaticBody3D

## Heavy teak wood wardrobe obstacle for Shadow of Lanna: Midnight Rite.
## Blocks passage and can only be pushed by the Brother (PlayerSibling3D.SiblingRole.BROTHER).

signal wardrobe_pushed()

@export var push_offset: Vector3 = Vector3(0, 0, 2.0)
@export var push_duration: float = 1.4

var is_pushed: bool = false
var _is_moving: bool = false
var _player_in_range: PlayerSibling3D = null

@onready var interact_area: Area3D = get_node_or_null("InteractArea")
@onready var prompt_label: Label3D = get_node_or_null("PromptLabel3D")

func _ready() -> void:
	# Layer 1 (World) & Layer 4 (Enemies/Props)
	collision_layer = 1 | 4
	collision_mask = 2 | 4

	if interact_area != null:
		interact_area.body_entered.connect(_on_interact_body_entered)
		interact_area.body_exited.connect(_on_interact_body_exited)

func _process(_delta: float) -> void:
	if is_pushed or _is_moving:
		if prompt_label != null:
			prompt_label.visible = false
		return

	if _player_in_range != null and prompt_label != null:
		if _player_in_range.is_active_player:
			prompt_label.visible = true
			if _player_in_range.sibling_role == PlayerSibling3D.SiblingRole.BROTHER:
				prompt_label.text = "[E] ผลักตู้ไม้สักเปิดทาง"
				prompt_label.modulate = Color(1.0, 0.95, 0.7, 1.0)
			else:
				prompt_label.text = "(หนักเกินไปสำหรับน้องสาว — ต้องให้พี่ชายช่วยดัน)"
				prompt_label.modulate = Color(0.9, 0.6, 0.4, 0.95)
		else:
			prompt_label.visible = false
	elif prompt_label != null:
		prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if is_pushed or _is_moving or _player_in_range == null or not _player_in_range.is_active_player:
		return

	if (InputMap.has_action("interact") and event.is_action_pressed("interact")) or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E):
		_try_push()

func _try_push() -> void:
	if _player_in_range.sibling_role != PlayerSibling3D.SiblingRole.BROTHER:
		if prompt_label != null:
			prompt_label.text = "(ต้องสลับเป็นพี่ชายเพื่อออกแรงดันตู้)"
			prompt_label.modulate = Color(1.0, 0.4, 0.4, 1.0)
		return

	_start_push()

func _start_push() -> void:
	_is_moving = true
	is_pushed = true

	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr != null and audio_mgr.has_method("play_creak_sound"):
		audio_mgr.play_creak_sound()

	var target_pos: Vector3 = position + push_offset
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_pos, push_duration)
	tween.finished.connect(func():
		_is_moving = false
		wardrobe_pushed.emit()
	)

func _on_interact_body_entered(body: Node3D) -> void:
	if body is PlayerSibling3D:
		_player_in_range = body

func _on_interact_body_exited(body: Node3D) -> void:
	if body == _player_in_range:
		_player_in_range = null
