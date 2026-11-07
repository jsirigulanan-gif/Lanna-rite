class_name LannaTung3D
extends Node3D

## Traditional northern Thai Lanna Tung banner in 3D.
## Features gentle atmospheric wind swaying animation.

@export var sway_speed: float = 1.6
@export var sway_amplitude: float = 0.08
@export var phase_offset: float = 0.0

@onready var banner_visual: Node3D = get_node_or_null("Visual")

func _process(delta: float) -> void:
	if banner_visual != null:
		var t: float = float(Time.get_ticks_msec()) / 1000.0 * sway_speed + phase_offset
		banner_visual.rotation.z = sin(t) * sway_amplitude
		banner_visual.rotation.x = sin(t * 0.7) * (sway_amplitude * 0.5)
