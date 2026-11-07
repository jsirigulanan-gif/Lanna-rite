class_name LannaTungBanner
extends Node2D

## Traditional hanging Lanna Tung (sacred banner) for Shadow of Lanna: Midnight Rite.
## Gently sways in the cold mountain draft, adding atmospheric visual fidelity.

@export var banner_color: Color = Color(0.85, 0.25, 0.22, 0.9)
@export var sway_speed: float = 2.0
@export var sway_angle_max: float = 0.08

var _time_offset: float = 0.0

@onready var visual_root: Node2D = get_node_or_null("Visual")
@onready var banner_body: ColorRect = get_node_or_null("Visual/BannerBody")

func _ready() -> void:
	_time_offset = randf() * 10.0
	if banner_body != null:
		banner_body.color = banner_color

func _process(delta: float) -> void:
	if visual_root != null:
		var current_time: float = (float(Time.get_ticks_msec()) / 1000.0) + _time_offset
		visual_root.rotation = sin(current_time * sway_speed) * sway_angle_max
