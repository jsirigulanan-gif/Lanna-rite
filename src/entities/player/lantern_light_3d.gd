class_name LanternLight3D
extends Node3D

## Lantern & dynamic 3D lighting controller for Shadow of Lanna: Midnight Rite.
## Uses real-time OmniLight3D and SpotLight3D with shadow casting for dramatic horror atmosphere.

signal fuel_changed(current_fuel: float, max_fuel: float)
signal fuel_depleted()

@export var max_fuel: float = 100.0
@export var burn_rate: float = 1.2 ## Fuel consumed per second while lit
@export var normal_energy: float = 1.8
@export var dim_energy: float = 0.4
@export var normal_range: float = 9.0
@export var dim_range: float = 3.5
@export var flicker_intensity: float = 0.08

var current_fuel: float = 100.0
var is_lit: bool = true
var _flicker_timer: float = 0.0

@onready var omni_light: OmniLight3D = get_node_or_null("OmniLight3D")
@onready var spot_light: SpotLight3D = get_node_or_null("SpotLight3D")

func _ready() -> void:
	add_to_group("lantern")
	current_fuel = max_fuel
	fuel_changed.emit(current_fuel, max_fuel)
	_update_light_appearance()

func _process(delta: float) -> void:
	if not is_lit:
		if omni_light != null:
			omni_light.visible = false
		if spot_light != null:
			spot_light.visible = false
		return

	if omni_light != null:
		omni_light.visible = true
	if spot_light != null:
		spot_light.visible = true

	if current_fuel > 0.0:
		current_fuel = maxf(0.0, current_fuel - (burn_rate * delta))
		fuel_changed.emit(current_fuel, max_fuel)
		if current_fuel <= 0.0:
			fuel_depleted.emit()

	_flicker_timer += delta * 12.0
	var flicker: float = sin(_flicker_timer) * flicker_intensity + sin(_flicker_timer * 2.3) * (flicker_intensity * 0.5)

	var target_energy: float = dim_energy if current_fuel <= 0.0 else normal_energy
	var target_range: float = dim_range if current_fuel <= 0.0 else normal_range

	if omni_light != null:
		omni_light.light_energy = maxf(0.05, target_energy + flicker)
		omni_light.omni_range = target_range
	if spot_light != null:
		spot_light.light_energy = maxf(0.05, (target_energy * 1.4) + flicker)
		spot_light.spot_range = target_range * 1.5

func _update_light_appearance() -> void:
	var target_energy: float = dim_energy if current_fuel <= 0.0 else normal_energy
	var target_range: float = dim_range if current_fuel <= 0.0 else normal_range
	if omni_light != null:
		omni_light.light_energy = target_energy
		omni_light.omni_range = target_range
	if spot_light != null:
		spot_light.light_energy = target_energy * 1.4
		spot_light.spot_range = target_range * 1.5

func add_fuel(amount: float) -> void:
	current_fuel = minf(max_fuel, current_fuel + amount)
	fuel_changed.emit(current_fuel, max_fuel)

func toggle_light() -> void:
	is_lit = not is_lit
