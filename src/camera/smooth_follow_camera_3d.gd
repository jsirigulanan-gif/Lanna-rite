class_name SmoothFollowCamera3D
extends Node3D

## Comfortable, Non-Dizzy Isometric / Top-Down 3D Smooth Follow Camera.
## Glides smoothly behind the active player sibling from a comfortable elevated angle (53° pitch).
## Features dynamic line-of-sight raycasting to make occluding walls transparent (20% alpha)
## whenever they block view of the siblings, and smoothly restores them when cleared.

@export var follow_speed: float = 5.5
@export var camera_offset: Vector3 = Vector3(0.0, 9.5, 7.2)
@export var pitch_degrees: float = -53.0
@export var occluded_alpha: float = 0.22
@export var fade_speed: float = 6.0

@onready var camera: Camera3D = get_node_or_null("Camera3D")

var target_node: Node3D = null
var _faded_meshes: Dictionary = {}

func _ready() -> void:
	if camera != null:
		camera.make_current()
		camera.rotation_degrees = Vector3(pitch_degrees, 0.0, 0.0)

	# Snap directly to target on first frame
	_find_target()
	if target_node != null:
		global_position = target_node.global_position + camera_offset

func _physics_process(delta: float) -> void:
	_find_target()
	if target_node == null:
		return

	var desired_pos: Vector3 = target_node.global_position + camera_offset
	global_position = global_position.lerp(desired_pos, clampf(delta * follow_speed, 0.0, 1.0))

	_update_wall_transparency(delta)

func _update_wall_transparency(delta: float) -> void:
	if camera == null:
		return

	var targets: Array[Node3D] = []
	if target_node != null:
		targets.append(target_node)

	var mgr: SiblingManager3D = get_tree().root.find_child("SiblingManager3D", true, false) as SiblingManager3D
	if mgr != null and mgr.get_inactive_sibling() != null:
		targets.append(mgr.get_inactive_sibling())

	var active_occluding_meshes: Array[MeshInstance3D] = []
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	for t in targets:
		var from_pos: Vector3 = camera.global_position
		var to_pos: Vector3 = t.global_position + Vector3(0, 1.1, 0)
		var exclude_rids: Array[RID] = []
		if t is CollisionObject3D:
			exclude_rids.append((t as CollisionObject3D).get_rid())

		for _i in range(5):
			var query := PhysicsRayQueryParameters3D.create(from_pos, to_pos)
			query.exclude = exclude_rids
			query.collision_mask = 1 # World layer
			var hit: Dictionary = space_state.intersect_ray(query)
			if hit.is_empty():
				break

			exclude_rids.append(hit.rid)
			var collider: Object = hit.collider
			if collider is StaticBody3D:
				for child in collider.get_children():
					if child is MeshInstance3D and not active_occluding_meshes.has(child):
						active_occluding_meshes.append(child)

	# Register newly occluding meshes
	for mesh_inst in active_occluding_meshes:
		if not _faded_meshes.has(mesh_inst):
			var mat: StandardMaterial3D = _get_or_create_override_material(mesh_inst)
			if mat != null:
				_faded_meshes[mesh_inst] = mat

	# Lerp alphas for all tracking meshes
	var meshes_to_remove: Array[MeshInstance3D] = []
	for mesh_inst in _faded_meshes.keys():
		var mat: StandardMaterial3D = _faded_meshes[mesh_inst]
		if not is_instance_valid(mesh_inst) or mat == null:
			meshes_to_remove.append(mesh_inst)
			continue

		var is_currently_blocking: bool = active_occluding_meshes.has(mesh_inst)
		var target_alpha: float = occluded_alpha if is_currently_blocking else 1.0
		mat.albedo_color.a = move_toward(mat.albedo_color.a, target_alpha, delta * fade_speed)

		if not is_currently_blocking and mat.albedo_color.a >= 0.99:
			mat.albedo_color.a = 1.0
			mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
			meshes_to_remove.append(mesh_inst)

	for m in meshes_to_remove:
		_faded_meshes.erase(m)

func _get_or_create_override_material(mesh_inst: MeshInstance3D) -> StandardMaterial3D:
	var mat: StandardMaterial3D = mesh_inst.get_surface_override_material(0) as StandardMaterial3D
	if mat == null:
		var base_mat: Material = mesh_inst.get_active_material(0)
		if base_mat is StandardMaterial3D:
			mat = (base_mat as StandardMaterial3D).duplicate() as StandardMaterial3D
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			mesh_inst.set_surface_override_material(0, mat)
	else:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat

func _find_target() -> void:
	var mgr: SiblingManager3D = get_tree().root.find_child("SiblingManager3D", true, false) as SiblingManager3D
	if mgr != null and mgr.get_active_sibling() != null:
		target_node = mgr.get_active_sibling()
		return

	for node in get_tree().get_nodes_in_group("player"):
		var sibling: PlayerSibling3D = node as PlayerSibling3D
		if sibling != null and sibling.is_active_player:
			target_node = sibling
			return
