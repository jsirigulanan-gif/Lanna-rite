class_name FixedCameraZone
extends Area2D

## Classic Resident Evil 1-3 style Fixed CCTV Camera Zone for Shadow of Lanna: Midnight Rite.
## When the player walks into this zone's trigger area, the camera instantly cuts to this zone's camera angle.

signal camera_activated(zone_name: String, camera: Camera2D)

@export var zone_name: String = "CCTV_Angle"
@export var is_initial_camera: bool = false
@export var zoom_level: Vector2 = Vector2(1.5, 1.5)

@onready var camera: Camera2D = get_node_or_null("Camera2D")

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player sibling layer
	body_entered.connect(_on_body_entered)

	if camera != null:
		camera.zoom = zoom_level

	if is_initial_camera and camera != null:
		activate_camera()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerSibling:
		activate_camera()

## Cuts the viewport to this fixed camera angle.
func activate_camera() -> void:
	if camera != null:
		camera.make_current()
		camera_activated.emit(zone_name, camera)
