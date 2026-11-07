class_name LanternLight
extends Node2D

## Lantern & dynamic 2D lighting controller for Shadow of Lanna: Midnight Rite.
## Manages PointLight2D intensity, radius, oil fuel consumption, and dimming warning states.

signal fuel_changed(current_fuel: float, max_fuel: float)
signal fuel_depleted()

@export var max_fuel: float = 100.0
@export var burn_rate: float = 1.5 ## Fuel units consumed per second while lit
@export var normal_energy: float = 1.0
@export var normal_scale: float = 1.6
@export var dim_energy: float = 0.25
@export var dim_scale: float = 0.6
@export var flicker_intensity: float = 0.05

var current_fuel: float = 100.0
var is_lit: bool = true
var _flicker_timer: float = 0.0

@onready var point_light: PointLight2D = get_node_or_null("PointLight2D")

func _ready() -> void:
	add_to_group("lantern")
	current_fuel = max_fuel
	_ensure_light_texture()
	fuel_changed.emit(current_fuel, max_fuel)
	_update_light_appearance()

func _ensure_light_texture() -> void:
	if point_light == null:
		point_light = PointLight2D.new()
		point_light.name = "PointLight2D"
		add_child(point_light)

	if point_light.texture == null:
		var gradient := Gradient.new()
		gradient.set_color(0, Color(1, 1, 1, 1))
		gradient.set_color(1, Color(1, 1, 1, 0))
		var grad_tex := GradientTexture2D.new()
		grad_tex.fill = GradientTexture2D.FILL_RADIAL
		grad_tex.fill_from = Vector2(0.5, 0.5)
		grad_tex.fill_to = Vector2(1.0, 0.5)
		grad_tex.gradient = gradient
		grad_tex.width = 256
		grad_tex.height = 256
		point_light.texture = grad_tex

func _process(delta: float) -> void:
	if not is_lit:
		if point_light != null:
			point_light.enabled = false
		return

	if point_light != null:
		point_light.enabled = true

	if current_fuel > 0.0:
		current_fuel = maxf(0.0, current_fuel - (burn_rate * delta))
		fuel_changed.emit(current_fuel, max_fuel)
		if current_fuel <= 0.0:
			fuel_depleted.emit()

	_update_light_appearance()
	_apply_flicker(delta)

func _update_light_appearance() -> void:
	if point_light == null:
		return

	var fuel_pct: float = current_fuel / max_fuel

	# When fuel is depleted or near 0, transition to dim state
	if fuel_pct <= 0.0:
		point_light.energy = dim_energy
		point_light.texture_scale = dim_scale
		point_light.color = Color(0.4, 0.45, 0.6, 1.0) # Cold ghostly blue/dim
	elif fuel_pct < 0.25:
		# Low fuel warning: warm amber dimming
		var t: float = fuel_pct / 0.25
		point_light.energy = lerpf(dim_energy, normal_energy, t)
		point_light.texture_scale = lerpf(dim_scale, normal_scale, t)
		point_light.color = Color(1.0, 0.7, 0.4, 1.0)
	else:
		# Full warm oil lamp glow
		point_light.energy = normal_energy
		point_light.texture_scale = normal_scale
		point_light.color = Color(1.0, 0.85, 0.55, 1.0)

func _apply_flicker(delta: float) -> void:
	if point_light == null:
		return

	_flicker_timer += delta * 12.0
	var offset: float = sin(_flicker_timer) * cos(_flicker_timer * 1.5) * flicker_intensity
	point_light.energy = maxf(0.05, point_light.energy + offset)

## Refuels the lantern with oil.
func add_fuel(amount: float) -> void:
	current_fuel = minf(max_fuel, current_fuel + amount)
	fuel_changed.emit(current_fuel, max_fuel)
	_update_light_appearance()

## Toggles the lantern on or off.
func toggle() -> void:
	is_lit = not is_lit
	if point_light != null:
		point_light.enabled = is_lit
