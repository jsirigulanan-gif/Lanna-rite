class_name FixedCameraZone3D
extends Area3D

## Classic Resident Evil / Silent Hill style Fixed CCTV Camera Zone in 3D.
## Features fixed vantage points with soft cinematic tracking to guarantee
## the player NEVER walks out of frame (ไม่หลุดเฟรม).

signal camera_activated(zone_name: String, camera: Camera3D)

@export var zone_name: String = "CCTV_Angle_3D"
@export var is_initial_camera: bool = false
@export var dynamic_tracking: bool = true ## Softly pan/tilt to keep player in shot
@export var tracking_speed: float = 3.5
@export var tracking_height_offset: float = 1.0

@onready var camera: Camera3D = get_node_or_null("Camera3D")

var is_active_zone: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player sibling layer
	body_entered.connect(_on_body_entered)

	if is_initial_camera and camera != null:
		call_deferred("activate_camera")

func _process(delta: float) -> void:
	if not is_active_zone or not dynamic_tracking or camera == null or not camera.current:
		return

	var target_player: PlayerSibling3D = _get_active_player()
	if target_player != null:
		var target_pos: Vector3 = target_player.global_position + Vector3(0, tracking_height_offset, 0)
		var current_transform: Transform3D = camera.global_transform
		var desired_transform: Transform3D = current_transform.looking_at(target_pos, Vector3.UP)
		camera.global_transform = current_transform.interpolate_with(desired_transform, clampf(delta * tracking_speed, 0.0, 1.0))

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerSibling3D and body.is_active_player:
		activate_camera()

## Cuts the viewport to this fixed 3D camera angle.
func activate_camera() -> void:
	if camera == null:
		return

	# Deactivate tracking on all other camera zones in the tree
	for zone in get_tree().get_nodes_in_group("camera_zones"):
		if zone is FixedCameraZone3D:
			zone.is_active_zone = false

	add_to_group("camera_zones")
	is_active_zone = true
	camera.make_current()
	camera_activated.emit(zone_name, camera)

func _get_active_player() -> PlayerSibling3D:
	var mgr: SiblingManager3D = get_tree().root.find_child("SiblingManager3D", true, false) as SiblingManager3D
	if mgr != null and mgr.get_active_sibling() != null:
		return mgr.get_active_sibling()

	for node in get_tree().get_nodes_in_group("player"):
		var sibling: PlayerSibling3D = node as PlayerSibling3D
		if sibling != null and sibling.is_active_player:
			return sibling
	return null
