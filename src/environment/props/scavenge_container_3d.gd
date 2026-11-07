class_name ScavengeContainer3D
extends Node3D

## Searchable desk / drawer container for Shadow of Lanna: Midnight Rite.
## Allows players to scavenge for lantern oil, holy cords, and herbal medicine in classrooms.

signal scavenged(item: ItemData)

@export var container_name: String = "โต๊ะครูประจำชั้น"
@export var possible_items: Array[ItemData] = []
@export var is_searched: bool = false
@export var open_offset: Vector3 = Vector3(0, 0, 0.3)

var _player_in_range: PlayerSibling3D = null

@onready var interact_area: Area3D = get_node_or_null("InteractArea")
@onready var prompt_label: Label3D = get_node_or_null("PromptLabel3D")
@onready var drawer_mesh: MeshInstance3D = get_node_or_null("DeskMesh/DrawerMesh")

func _ready() -> void:
	if interact_area != null:
		interact_area.body_entered.connect(_on_interact_body_entered)
		interact_area.body_exited.connect(_on_interact_body_exited)

	if is_searched and drawer_mesh != null:
		drawer_mesh.position += open_offset

func _process(_delta: float) -> void:
	if _player_in_range != null and prompt_label != null:
		if _player_in_range.is_active_player:
			prompt_label.visible = true
			if is_searched:
				prompt_label.text = "(ว่างเปล่า — ค้นไปแล้ว)"
				prompt_label.modulate = Color(0.65, 0.65, 0.65, 0.8)
			else:
				prompt_label.text = "[E] ค้นหาของในลิ้นชักโต๊ะ"
				prompt_label.modulate = Color(1.0, 0.95, 0.7, 1.0)
		else:
			prompt_label.visible = false
	elif prompt_label != null:
		prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range == null or not _player_in_range.is_active_player:
		return

	if (InputMap.has_action("interact") and event.is_action_pressed("interact")) or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E):
		_try_scavenge()

func _try_scavenge() -> void:
	if is_searched:
		return

	is_searched = true

	var audio_mgr = get_node_or_null("/root/AudioManager")
	if audio_mgr != null and audio_mgr.has_method("play_creak_sound"):
		audio_mgr.play_creak_sound()

	if drawer_mesh != null:
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(drawer_mesh, "position", drawer_mesh.position + open_offset, 0.4)

	var item_to_give: ItemData = null
	if not possible_items.is_empty():
		item_to_give = possible_items[randi() % possible_items.size()]

	if item_to_give != null:
		var inv: InventoryGrid = get_tree().root.find_child("InventoryGrid", true, false) as InventoryGrid
		if inv != null:
			var added: bool = inv.add_item(item_to_give)
			if added:
				if prompt_label != null:
					prompt_label.text = "ได้รับ: " + item_to_give.item_name
					prompt_label.modulate = Color(0.3, 1.0, 0.4, 1.0)
			else:
				if prompt_label != null:
					prompt_label.text = "ช่องเก็บของเต็ม! (วางทิ้งไว้บนโต๊ะ)"
					prompt_label.modulate = Color(1.0, 0.4, 0.4, 1.0)
		scavenged.emit(item_to_give)
	else:
		if prompt_label != null:
			prompt_label.text = "(ไม่พบสิ่งของใดๆ)"
			prompt_label.modulate = Color(0.7, 0.7, 0.7, 1.0)

func _on_interact_body_entered(body: Node3D) -> void:
	if body is PlayerSibling3D:
		_player_in_range = body

func _on_interact_body_exited(body: Node3D) -> void:
	if body == _player_in_range:
		_player_in_range = null
