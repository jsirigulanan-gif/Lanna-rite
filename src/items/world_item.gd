class_name WorldItem
extends Area2D

## Interactive item placed in the game world.
## Allows players to pick up items into their inventory when in range.

signal item_picked_up(item: ItemData)

@export var item_data: ItemData = null
@export var prompt_text: String = "กด E หรือคลิก เพื่อเก็บ"

var _player_in_range: PlayerSibling = null

@onready var visual_rect: ColorRect = get_node_or_null("Visual/ColorRect")
@onready var prompt_label: Label = get_node_or_null("PromptLabel")

func _ready() -> void:
	collision_layer = 8
	collision_mask = 2 # Player layer
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_appearance()
	if prompt_label != null:
		prompt_label.visible = false

func _update_appearance() -> void:
	if item_data != null and visual_rect != null:
		visual_rect.color = item_data.icon_color

func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range != null:
		if (InputMap.has_action("interact") and event.is_action_pressed("interact")) or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E):
			attempt_pickup()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerSibling:
		_player_in_range = body
		if prompt_label != null:
			var display_name: String = item_data.item_name if item_data != null else "ไอเทม"
			prompt_label.text = "[E] เก็บ " + display_name
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null
		if prompt_label != null:
			prompt_label.visible = false

## Attempts to place the item into the active inventory.
func attempt_pickup() -> bool:
	if item_data == null:
		return false

	# Find active inventory in UI
	var inventory: InventoryGrid = get_tree().root.find_child("InventoryGrid", true, false) as InventoryGrid
	if inventory != null:
		var success: bool = inventory.add_item(item_data)
		if success:
			item_picked_up.emit(item_data)
			queue_free()
			return true
		else:
			inventory.show_full_notification()
			return false
	return false
