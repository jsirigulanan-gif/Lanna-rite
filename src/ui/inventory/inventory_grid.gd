class_name InventoryGrid
extends Control

## Classic survival horror grid inventory system for Shadow of Lanna: Midnight Rite.
## Manages an 8-slot inventory grid, item usage, examination, dropping, and fullness notifications.

signal item_used(item: ItemData)
signal item_dropped(item: ItemData)
signal inventory_toggled(is_open: bool)

@export var max_slots: int = 8
@export var world_item_scene: PackedScene = preload("res://src/items/world_item.tscn")

var slots: Array[ItemData] = []
var selected_index: int = -1

@onready var grid_container: GridContainer = get_node_or_null("Panel/GridContainer")
@onready var action_menu: Panel = get_node_or_null("ActionMenu")
@onready var examine_panel: Panel = get_node_or_null("ExaminePanel")
@onready var examine_title: Label = get_node_or_null("ExaminePanel/TitleLabel")
@onready var examine_body: Label = get_node_or_null("ExaminePanel/DescriptionLabel")
@onready var notification_label: Label = get_node_or_null("NotificationLabel")

func _ready() -> void:
	# Initialize empty slots
	slots.resize(max_slots)
	for i in range(max_slots):
		slots[i] = null

	visible = false
	if action_menu != null:
		action_menu.visible = false
	if examine_panel != null:
		examine_panel.visible = false
	if notification_label != null:
		notification_label.visible = false

	_refresh_ui()

func _unhandled_input(event: InputEvent) -> void:
	if (InputMap.has_action("toggle_inventory") and event.is_action_pressed("toggle_inventory")) or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_I):
		toggle_inventory()

## Toggles inventory window visibility.
func toggle_inventory() -> void:
	visible = not visible
	if not visible:
		if action_menu != null:
			action_menu.visible = false
		if examine_panel != null:
			examine_panel.visible = false
	inventory_toggled.emit(visible)

## Adds an item to the first available empty slot.
func add_item(item: ItemData) -> bool:
	if item == null:
		return false

	for i in range(max_slots):
		if slots[i] == null:
			slots[i] = item
			_refresh_ui()
			var audio: AudioManager = get_tree().root.find_child("AudioManager", true, false) as AudioManager
			if audio != null:
				audio.play_pickup_sound()
			return true

	show_full_notification()
	return false

## Removes an item at a specific slot index.
func remove_item_at(index: int) -> ItemData:
	if index < 0 or index >= max_slots or slots[index] == null:
		return null

	var item: ItemData = slots[index]
	slots[index] = null
	_refresh_ui()
	return item

## Checks if inventory has an item by its ID.
func has_item(item_id: String) -> bool:
	for item in slots:
		if item != null and item.id == item_id:
			return true
	return false

## Selects a slot index and displays the action popup menu.
func select_slot(index: int) -> void:
	if index < 0 or index >= max_slots or slots[index] == null:
		if action_menu != null:
			action_menu.visible = false
		return

	selected_index = index
	if action_menu != null:
		action_menu.visible = true

## Executes the "Use" action on the currently selected item.
func use_selected_item() -> void:
	if selected_index < 0 or selected_index >= max_slots:
		return

	var item: ItemData = slots[selected_index]
	if item == null:
		return

	var used_successfully: bool = false

	# 1. Fuel recovery effect (for lantern)
	if item.fuel_amount > 0.0:
		var lanterns: Array[Node] = get_tree().get_nodes_in_group("lantern")
		if lanterns.is_empty():
			# Fallback: search for LanternLight in player siblings
			var scene_root: Node = get_tree().current_scene if get_tree().current_scene != null else get_parent()
			if scene_root != null:
				for lantern_node in scene_root.find_children("*", "LanternLight", true, false):
					lanterns.append(lantern_node)

		for l in lanterns:
			var lantern_ref: LanternLight = l as LanternLight
			if lantern_ref != null:
				lantern_ref.add_fuel(item.fuel_amount)
				used_successfully = true

	# 2. Health recovery effect (for active player)
	if item.heal_amount > 0:
		var sibling_mgr: SiblingManager = get_tree().root.find_child("SiblingManager", true, false) as SiblingManager
		if sibling_mgr != null and sibling_mgr.get_active_sibling() != null:
			sibling_mgr.get_active_sibling().heal(item.heal_amount)
			used_successfully = true
		else:
			# Fallback: heal first player sibling found
			var scene_root: Node = get_tree().current_scene if get_tree().current_scene != null else get_parent()
			if scene_root != null:
				var first_sibling: PlayerSibling = scene_root.find_child("*", true, false) as PlayerSibling
				if first_sibling != null:
					first_sibling.heal(item.heal_amount)
					used_successfully = true

	# 3. Holy Water splash effect (Emergency defensive stun)
	if item.id == "holy_water":
		var mgr: SiblingManager = get_tree().root.find_child("SiblingManager", true, false) as SiblingManager
		var user_pos: Vector2 = Vector2.ZERO
		if mgr != null and mgr.get_active_sibling() != null:
			user_pos = mgr.get_active_sibling().global_position

		var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
		for e in enemies:
			var spirit: SpiritAI = e as SpiritAI
			if spirit != null and spirit.global_position.distance_to(user_pos) <= 140.0:
				var knockback_dir: Vector2 = (spirit.global_position - user_pos).normalized()
				if knockback_dir.length_squared() < 0.01:
					knockback_dir = Vector2.UP
				spirit.apply_stun(6.0, knockback_dir * 320.0)
		used_successfully = true

	# Key items or puzzle items can also be marked as used
	if item.item_type == ItemData.ItemType.KEY_ITEM or item.item_type == ItemData.ItemType.PUZZLE:
		used_successfully = true

	if used_successfully:
		item_used.emit(item)
		slots[selected_index] = null
		selected_index = -1
		if action_menu != null:
			action_menu.visible = false
		_refresh_ui()

## Opens examine lore dialog for the selected item.
func examine_selected_item() -> void:
	if selected_index < 0 or selected_index >= max_slots:
		return

	var item: ItemData = slots[selected_index]
	if item == null or examine_panel == null:
		return

	if examine_title != null:
		examine_title.text = item.item_name
	if examine_body != null:
		examine_body.text = item.description
	examine_panel.visible = true

## Drops the selected item back into the world.
func drop_selected_item() -> void:
	if selected_index < 0 or selected_index >= max_slots:
		return

	var item: ItemData = slots[selected_index]
	if item == null:
		return

	# Drop into world near player
	var spawn_pos: Vector2 = Vector2.ZERO
	var sibling_mgr: SiblingManager = get_tree().root.find_child("SiblingManager", true, false) as SiblingManager
	if sibling_mgr != null and sibling_mgr.get_active_sibling() != null:
		spawn_pos = sibling_mgr.get_active_sibling().global_position + Vector2(24.0, 0.0)

	if world_item_scene != null:
		var world_item: WorldItem = world_item_scene.instantiate() as WorldItem
		if world_item != null:
			world_item.item_data = item
			world_item.global_position = spawn_pos
			get_tree().current_scene.add_child(world_item)

	item_dropped.emit(item)
	slots[selected_index] = null
	selected_index = -1
	if action_menu != null:
		action_menu.visible = false
	_refresh_ui()

## Shows inventory full notification.
func show_full_notification() -> void:
	if notification_label != null:
		notification_label.text = "ช่องสัมภาระเต็มแล้ว! (Inventory Full)"
		notification_label.visible = true
		get_tree().create_timer(2.5).timeout.connect(func(): notification_label.visible = false)

func _refresh_ui() -> void:
	if grid_container == null:
		return

	var child_count: int = grid_container.get_child_count()
	for i in range(max_slots):
		var btn: Button = null
		if i < child_count:
			btn = grid_container.get_child(i) as Button
		else:
			btn = Button.new()
			btn.custom_minimum_size = Vector2(56, 56)
			var idx: int = i
			btn.pressed.connect(func(): select_slot(idx))
			grid_container.add_child(btn)

		if slots[i] != null:
			btn.text = slots[i].item_name
			btn.tooltip_text = slots[i].description
		else:
			btn.text = "[ ว่าง ]"
			btn.tooltip_text = "ช่องว่าง"
