class_name SaiSinWard3D
extends Node3D

## 3D Holy Thread (Sai Sin) Ward Doorway Barricade for Shadow of Lanna: Midnight Rite.
## When deployed by the Brother using Sai Sin Cord, it blocks and repels spirits (SpiritAI3D),
## while allowing the player siblings to pass freely.

signal ward_deployed()
signal spirit_repelled(spirit: Node3D)

@export var is_deployed: bool = false
@export var ward_width: float = 2.2
@export var repel_stun_duration: float = 4.0
@export var repel_push_force: float = 4.5

var _player_in_range: PlayerSibling3D = null

@onready var interact_area: Area3D = get_node_or_null("InteractArea")
@onready var repel_area: Area3D = get_node_or_null("RepelArea")
@onready var static_barrier: StaticBody3D = get_node_or_null("StaticBarrier")
@onready var threads_visual: Node3D = get_node_or_null("ThreadsVisual")
@onready var holy_light: OmniLight3D = get_node_or_null("HolyLight3D")
@onready var prompt_label: Label3D = get_node_or_null("PromptLabel3D")

func _ready() -> void:
	if interact_area != null:
		interact_area.body_entered.connect(_on_interact_body_entered)
		interact_area.body_exited.connect(_on_interact_body_exited)

	if repel_area != null:
		repel_area.body_entered.connect(_on_repel_body_entered)

	_update_ward_state()

func _process(_delta: float) -> void:
	if is_deployed:
		if prompt_label != null:
			prompt_label.visible = false
		return

	if _player_in_range != null and prompt_label != null:
		if _player_in_range.is_active_player:
			prompt_label.visible = true
			if _player_in_range.sibling_role == PlayerSibling3D.SiblingRole.BROTHER:
				prompt_label.text = "[E] ขึงสายสิญจน์ป้องกันผี"
				prompt_label.modulate = Color(1.0, 0.95, 0.7, 1.0)
			else:
				prompt_label.text = "(พี่ชายเท่านั้นที่ขึงสายสิญจน์ได้)"
				prompt_label.modulate = Color(0.7, 0.7, 0.7, 0.9)
		else:
			prompt_label.visible = false
	elif prompt_label != null:
		prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if is_deployed or _player_in_range == null or not _player_in_range.is_active_player:
		return

	if (InputMap.has_action("interact") and event.is_action_pressed("interact")) or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E):
		_try_deploy_ward()

func _try_deploy_ward() -> void:
	if _player_in_range.sibling_role != PlayerSibling3D.SiblingRole.BROTHER:
		_show_feedback("(ต้องสลับเป็นพี่ชายเพื่อทำพิธีขึงสายสิญจน์)")
		return

	# Check inventory
	var inv: InventoryGrid = get_tree().root.find_child("InventoryGrid", true, false) as InventoryGrid
	if inv != null:
		if inv.has_item("saisin_cord"):
			inv.remove_item_by_id("saisin_cord")
			deploy()
		else:
			_show_feedback("(ไม่มีม้วนด้ายสายสิญจน์ในกระเป๋า)")
	else:
		# Fallback if no inventory UI in test scene: deploy directly
		deploy()

func deploy() -> void:
	is_deployed = true
	_update_ward_state()
	ward_deployed.emit()

	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr != null and audio_mgr.has_method("play_pickup_sound"):
		audio_mgr.play_pickup_sound()

func _update_ward_state() -> void:
	if threads_visual != null:
		threads_visual.visible = is_deployed
	if holy_light != null:
		holy_light.visible = is_deployed
	if static_barrier != null:
		# Layer 4 blocks enemy navigation & movement
		static_barrier.collision_layer = 4 if is_deployed else 0
		static_barrier.collision_mask = 4 if is_deployed else 0

func _on_interact_body_entered(body: Node3D) -> void:
	if body is PlayerSibling3D:
		_player_in_range = body

func _on_interact_body_exited(body: Node3D) -> void:
	if body == _player_in_range:
		_player_in_range = null

func _on_repel_body_entered(body: Node3D) -> void:
	if not is_deployed:
		return

	if body is SpiritAI3D or body.is_in_group("enemies"):
		_repel_spirit(body)

func _repel_spirit(spirit: Node3D) -> void:
	var push_dir: Vector3 = (spirit.global_position - global_position).normalized()
	push_dir.y = 0.0
	if push_dir.length_squared() < 0.01:
		push_dir = -global_transform.basis.z

	# Apply push back
	if "velocity" in spirit:
		spirit.velocity = push_dir * repel_push_force * 3.0

	if spirit.has_method("stun"):
		spirit.stun(repel_stun_duration)

	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr != null and audio_mgr.has_method("play_ghost_screech"):
		audio_mgr.play_ghost_screech()

	spirit_repelled.emit(spirit)

func _show_feedback(msg: String) -> void:
	if prompt_label != null:
		prompt_label.text = msg
		prompt_label.modulate = Color(1.0, 0.4, 0.4, 1.0)
