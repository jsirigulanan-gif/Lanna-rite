class_name AltarShrine3D
extends Area3D

## Sacred ritual altar in the 3D village courtyard.
## Siblings must extinguish the ritual fire to break the curse and open the escape route.

signal altar_cleansed()

@export var altar_name: String = "แท่นบูชายัญลานศาลผี"
@export var is_extinguished: bool = false

var _player_nearby: PlayerSibling3D = null
var _flame_timer: float = 0.0

@onready var flame_light: OmniLight3D = get_node_or_null("FlameLight3D")
@onready var flame_mesh: MeshInstance3D = get_node_or_null("Visual/FlameMesh")
@onready var prompt_label: Label3D = get_node_or_null("PromptLabel3D")
@onready var ember_particles: GPUParticles3D = get_node_or_null("EmberParticles3D")

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player sibling
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label != null:
		prompt_label.visible = false
	_update_appearance()

func _process(delta: float) -> void:
	if not is_extinguished and flame_light != null:
		_flame_timer += delta * 15.0
		flame_light.light_energy = 2.0 + sin(_flame_timer) * 0.35 + sin(_flame_timer * 2.7) * 0.2

func _unhandled_input(event: InputEvent) -> void:
	if _player_nearby != null and not is_extinguished:
		if (InputMap.has_action("interact") and event.is_action_pressed("interact")) or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E):
			extinguish_altar()

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerSibling3D and not is_extinguished:
		_player_nearby = body as PlayerSibling3D
		if prompt_label != null:
			prompt_label.text = "[E] ดับไฟพิธีกรรมล้านนา"
			prompt_label.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body == _player_nearby:
		_player_nearby = null
		if prompt_label != null:
			prompt_label.visible = false

func extinguish_altar() -> void:
	if is_extinguished:
		return
	is_extinguished = true
	_update_appearance()

	var gm: GameManager = get_tree().root.find_child("GameManager", true, false) as GameManager
	if gm != null:
		gm.cleanse_altar()

	if prompt_label != null:
		prompt_label.text = "ไฟดับแล้ว! รีบหนีไปทางออก!"
		prompt_label.visible = true

	altar_cleansed.emit()

func _update_appearance() -> void:
	if flame_light != null:
		flame_light.visible = not is_extinguished
	if flame_mesh != null:
		flame_mesh.visible = not is_extinguished
	if ember_particles != null:
		ember_particles.emitting = not is_extinguished
