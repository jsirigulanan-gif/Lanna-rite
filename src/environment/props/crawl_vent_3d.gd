class_name CrawlVent3D
extends Node3D

## Narrow ventilation crawl space obstacle for Shadow of Lanna: Midnight Rite.
## Only the smaller Sister (PlayerSibling3D.SiblingRole.SISTER) can squeeze through.
## Once inside, she can interact with an interior door latch to let the Brother in.

signal crawl_started(sibling: PlayerSibling3D)
signal crawl_finished(sibling: PlayerSibling3D)
signal door_unlocked_from_inside()

@export var exit_offset: Vector3 = Vector3(0, 0, 3.2)
@export var crawl_duration: float = 1.0
@export var target_door: Node3D = null

var _player_in_range: PlayerSibling3D = null
var _is_crawling: bool = false
var _is_door_unlocked: bool = false

@onready var interact_area: Area3D = get_node_or_null("InteractArea")
@onready var prompt_label: Label3D = get_node_or_null("PromptLabel3D")
@onready var exit_marker: Marker3D = get_node_or_null("ExitMarker")
@onready var interior_latch_area: Area3D = get_node_or_null("InteriorLatchArea")
@onready var latch_prompt_label: Label3D = get_node_or_null("InteriorLatchArea/LatchPromptLabel3D")

func _ready() -> void:
	if interact_area != null:
		interact_area.body_entered.connect(_on_interact_body_entered)
		interact_area.body_exited.connect(_on_interact_body_exited)

	if interior_latch_area != null:
		interior_latch_area.body_entered.connect(_on_latch_body_entered)
		interior_latch_area.body_exited.connect(_on_latch_body_exited)

func _process(_delta: float) -> void:
	if _is_crawling:
		if prompt_label != null:
			prompt_label.visible = false
		return

	if _player_in_range != null and prompt_label != null:
		if _player_in_range.is_active_player:
			prompt_label.visible = true
			if _player_in_range.sibling_role == PlayerSibling3D.SiblingRole.SISTER:
				prompt_label.text = "[E] มุดลอดช่องแคบ"
				prompt_label.modulate = Color(1.0, 0.95, 0.7, 1.0)
			else:
				prompt_label.text = "(ตัวใหญ่เกินไป — น้องสาวเท่านั้นที่มุดได้)"
				prompt_label.modulate = Color(0.9, 0.6, 0.4, 0.95)
		else:
			prompt_label.visible = false
	elif prompt_label != null:
		prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _is_crawling:
		return

	if (InputMap.has_action("interact") and event.is_action_pressed("interact")) or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E):
		if _player_in_range != null and _player_in_range.is_active_player:
			_try_crawl()

func _try_crawl() -> void:
	if _player_in_range.sibling_role != PlayerSibling3D.SiblingRole.SISTER:
		if prompt_label != null:
			prompt_label.text = "(ต้องสลับเป็นน้องสาวเพื่อมุดช่องแคบ)"
			prompt_label.modulate = Color(1.0, 0.4, 0.4, 1.0)
		return

	_start_crawl(_player_in_range)

func _start_crawl(sibling: PlayerSibling3D) -> void:
	_is_crawling = true
	crawl_started.emit(sibling)

	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr != null and audio_mgr.has_method("play_creak_sound"):
		audio_mgr.play_creak_sound()

	var dest: Vector3 = exit_marker.global_position if exit_marker != null else global_position + exit_offset
	dest.y = sibling.global_position.y

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sibling, "global_position", dest, crawl_duration)
	tween.finished.connect(func():
		_is_crawling = false
		crawl_finished.emit(sibling)
	)

func _on_interact_body_entered(body: Node3D) -> void:
	if body is PlayerSibling3D:
		_player_in_range = body

func _on_interact_body_exited(body: Node3D) -> void:
	if body == _player_in_range:
		_player_in_range = null

func _on_latch_body_entered(body: Node3D) -> void:
	if not _is_door_unlocked and body is PlayerSibling3D and body.is_active_player:
		if latch_prompt_label != null:
			latch_prompt_label.visible = true

func _on_latch_body_exited(body: Node3D) -> void:
	if body is PlayerSibling3D and latch_prompt_label != null:
		latch_prompt_label.visible = false

## Unlocks the linked target door from the inside
func unlock_interior_door() -> void:
	if _is_door_unlocked:
		return
	_is_door_unlocked = true
	if latch_prompt_label != null:
		latch_prompt_label.visible = false

	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr != null and audio_mgr.has_method("play_creak_sound"):
		audio_mgr.play_creak_sound()

	if target_door != null:
		if target_door.has_method("unlock"):
			target_door.unlock()
		elif target_door.has_method("open_door"):
			target_door.open_door()
		else:
			target_door.queue_free()

	door_unlocked_from_inside.emit()
