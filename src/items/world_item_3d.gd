class_name WorldItem3D
extends Area3D

## Interactive 3D item placed in the game world for Shadow of Lanna: Midnight Rite.
## Allows players to pick up items into their inventory when in range.

signal item_picked_up(item: ItemData)

@export var item_data: ItemData = null

var _player_in_range: PlayerSibling3D = null

@onready var visual: Node3D = get_node_or_null("Visual")
@onready var item_mesh: MeshInstance3D = get_node_or_null("Visual/ItemMesh")
@onready var item_light: OmniLight3D = get_node_or_null("ItemLight3D")
@onready var prompt_label: Label3D = get_node_or_null("PromptLabel3D")

func _ready() -> void:
	collision_layer = 8
	collision_mask = 2 # Player sibling
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_appearance()
	if prompt_label != null:
		prompt_label.visible = false

func _process(delta: float) -> void:
	if visual != null:
		visual.rotate_y(delta * 2.2)

func _update_appearance() -> void:
	if item_data != null:
		if item_light != null:
			item_light.light_color = item_data.icon_color
		if item_mesh != null and item_mesh.material_override != null:
			var mat: StandardMaterial3D = item_mesh.material_override as StandardMaterial3D
			if mat != null:
				mat.albedo_color = item_data.icon_color
				mat.emission = item_data.icon_color

func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range != null:
		if (InputMap.has_action("interact") and event.is_action_pressed("interact")) or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E):
			attempt_pickup()

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerSibling3D:
		_player_in_range = body
		if prompt_label != null:
			var display_name: String = item_data.item_name if item_data != null else "ไอเทม"
			prompt_label.text = "[E] เก็บ " + display_name
			prompt_label.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body == _player_in_range:
		_player_in_range = null
		if prompt_label != null:
			prompt_label.visible = false

func attempt_pickup() -> bool:
	if item_data == null:
		return false

	var inventory: InventoryGrid = get_tree().root.find_child("InventoryGrid", true, false) as InventoryGrid
	if inventory != null:
		var success: bool = inventory.add_item(item_data)
		if success:
			var audio_mgr = get_node_or_null("/root/AudioManager")
			if audio_mgr != null and audio_mgr.has_method("play_item_pickup"):
				audio_mgr.play_item_pickup()

			item_picked_up.emit(item_data)
			queue_free()
			return true
		else:
			inventory.show_full_notification()
			return false
	return false
