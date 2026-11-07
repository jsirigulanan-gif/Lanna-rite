class_name AltarShrine
extends Area2D

## Sacred ritual altar in the village courtyard.
## Siblings must extinguish the ritual fire to break the curse and open the escape route.

signal altar_cleansed()

@export var altar_name: String = "แท่นบูชายัญลานศาลผี"
@export var is_extinguished: bool = false

var _player_nearby: PlayerSibling = null

@onready var prompt_label: Label = get_node_or_null("PromptLabel")
@onready var flame_visual: ColorRect = get_node_or_null("Visual/FlameRect")
@onready var flame_light: PointLight2D = get_node_or_null("PointLight2D")

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label != null:
		prompt_label.visible = false
	_update_appearance()

func _unhandled_input(event: InputEvent) -> void:
	if _player_nearby != null and not is_extinguished:
		if (InputMap.has_action("interact") and event.is_action_pressed("interact")) or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E):
			extinguish_altar()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerSibling and not is_extinguished:
		_player_nearby = body as PlayerSibling
		if prompt_label != null:
			prompt_label.text = "[E] ดับไฟพิธีกรรมและทำลายเครื่องเซ่น"
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body == _player_nearby:
		_player_nearby = null
		if prompt_label != null:
			prompt_label.visible = false

## Extinguishes the sacrificial flame and cleanses the shrine.
func extinguish_altar() -> void:
	if is_extinguished:
		return
	is_extinguished = true
	_update_appearance()

	var gm: GameManager = get_tree().root.find_child("GameManager", true, false) as GameManager
	if gm != null:
		gm.cleanse_altar()

	if prompt_label != null:
		prompt_label.text = "ไฟพิธีกรรมดับมอดแล้ว! รีบหนีไปที่ประตูรั้วหมู่บ้าน!"

	altar_cleansed.emit()

func _update_appearance() -> void:
	if flame_visual != null:
		if is_extinguished:
			flame_visual.color = Color(0.2, 0.2, 0.25, 0.3) # Dim ash
			if flame_light != null:
				flame_light.enabled = false
		else:
			flame_visual.color = Color(1.0, 0.45, 0.1, 0.95) # Eerie sacrificial flame
			if flame_light != null:
				flame_light.enabled = true
