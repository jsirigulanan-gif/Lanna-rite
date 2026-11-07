class_name StatusHUD
extends Control

## Classic Resident Evil style status HUD for Shadow of Lanna: Midnight Rite.
## Displays EKG health condition (FINE, CAUTION, DANGER), active sibling, stamina, and lantern oil.

@onready var character_name_label: Label = get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer/HeaderHBox/CharacterNameLabel")
@onready var condition_label: Label = get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer/HeaderHBox/ConditionLabel")
@onready var health_bar: ProgressBar = get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer/HealthBar")
@onready var stamina_bar: ProgressBar = get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer/StaminaBar")
@onready var lantern_box: VBoxContainer = get_node_or_null("MarginContainer/HBoxContainer/LanternVBox")
@onready var lantern_fuel_bar: ProgressBar = get_node_or_null("MarginContainer/HBoxContainer/LanternVBox/LanternBar")
@onready var lantern_pct_label: Label = get_node_or_null("MarginContainer/HBoxContainer/LanternVBox/FuelLabel")

var _current_active_sibling: Node = null

func _ready() -> void:
	_hook_signals()

func _hook_signals() -> void:
	# Hook SiblingManager (2D or 3D)
	var mgr: Node = get_tree().root.find_child("SiblingManager3D", true, false)
	if mgr == null:
		mgr = get_tree().root.find_child("SiblingManager", true, false)

	if mgr != null:
		if mgr.has_signal("character_switched"):
			mgr.character_switched.connect(_on_character_switched)
		if mgr.has_method("get_active_sibling") and mgr.get_active_sibling() != null:
			_bind_sibling(mgr.get_active_sibling())

	# Hook Lantern (2D or 3D)
	var lanterns: Array[Node] = get_tree().get_nodes_in_group("lantern")
	for l in lanterns:
		if l.has_signal("fuel_changed"):
			l.fuel_changed.connect(_on_lantern_fuel_changed)
			var cur_fuel: float = l.current_fuel if "current_fuel" in l else 100.0
			var mx_fuel: float = l.max_fuel if "max_fuel" in l else 100.0
			_on_lantern_fuel_changed(cur_fuel, mx_fuel)

func _on_character_switched(active: Node, _inactive: Node) -> void:
	_bind_sibling(active)

func _bind_sibling(sibling: Node) -> void:
	if sibling == null:
		return

	if _current_active_sibling != null:
		# Disconnect previous if needed
		if _current_active_sibling.health_changed.is_connected(_on_health_changed):
			_current_active_sibling.health_changed.disconnect(_on_health_changed)
		if _current_active_sibling.stamina_changed.is_connected(_on_stamina_changed):
			_current_active_sibling.stamina_changed.disconnect(_on_stamina_changed)

	_current_active_sibling = sibling
	_current_active_sibling.health_changed.connect(_on_health_changed)
	_current_active_sibling.stamina_changed.connect(_on_stamina_changed)

	if character_name_label != null:
		character_name_label.text = sibling.character_name

	_on_health_changed(sibling.current_health, sibling.max_health)
	_on_stamina_changed(sibling.current_stamina, sibling.max_stamina)

func _on_health_changed(curr: int, max_hp: int) -> void:
	var pct: float = float(curr) / float(max_hp) if max_hp > 0 else 0.0

	if health_bar != null:
		health_bar.max_value = max_hp
		health_bar.value = curr

	if condition_label != null:
		if pct > 0.6:
			condition_label.text = "[ FINE ]"
			condition_label.modulate = Color(0.2, 0.9, 0.4, 1.0) # Green
		elif pct > 0.25:
			condition_label.text = "[ CAUTION ]"
			condition_label.modulate = Color(0.95, 0.75, 0.2, 1.0) # Amber
		else:
			condition_label.text = "[ DANGER ]"
			condition_label.modulate = Color(0.95, 0.2, 0.2, 1.0) # Crimson

func _on_stamina_changed(curr: float, max_stamina: float) -> void:
	if stamina_bar != null:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = curr

func _on_lantern_fuel_changed(curr: float, max_fuel: float) -> void:
	var pct: float = float(curr) / float(max_fuel) if max_fuel > 0 else 0.0
	if lantern_fuel_bar != null:
		lantern_fuel_bar.max_value = max_fuel
		lantern_fuel_bar.value = curr

	if lantern_pct_label != null:
		var has_lantern: bool = _current_active_sibling != null and _current_active_sibling.get_node_or_null("LanternLight3D") != null
		if has_lantern:
			lantern_pct_label.text = "น้ำมัน: " + str(int(pct * 100)) + "% [RMB/F รวมแสง]"
		else:
			lantern_pct_label.text = "น้ำมัน: " + str(int(pct * 100)) + "%"
