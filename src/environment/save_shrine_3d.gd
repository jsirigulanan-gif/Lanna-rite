class_name SaveShrine3D
extends Area3D

## Classic Resident Evil Typewriter style Save Station in 3D for Shadow of Lanna: Midnight Rite.
## Traditional Lanna spirit shrine with flickering sacred candles allowing players to save.

signal game_saved()

@export var shrine_name: String = "ศาลพระภูมิเรือนไม้ (จุดบันทึกเกม)"

var _player_nearby: PlayerSibling3D = null
var _save_file_path: String = "user://savegame.json"

@onready var prompt_label: Label3D = get_node_or_null("PromptLabel3D")
@onready var candle_light: OmniLight3D = get_node_or_null("CandleLight3D")

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player sibling
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label != null:
		prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _player_nearby != null:
		if (InputMap.has_action("interact") and event.is_action_pressed("interact")) or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E):
			save_game()

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerSibling3D:
		_player_nearby = body as PlayerSibling3D
		if prompt_label != null:
			prompt_label.text = "[E] บันทึกความทรงจำ (เซฟเกม)"
			prompt_label.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body == _player_nearby:
		_player_nearby = null
		if prompt_label != null:
			prompt_label.visible = false

func save_game() -> void:
	var save_data := {}

	var mgr: SiblingManager3D = get_tree().root.find_child("SiblingManager3D", true, false) as SiblingManager3D
	if mgr != null and mgr.get_active_sibling() != null:
		var active: PlayerSibling3D = mgr.get_active_sibling()
		save_data["active_sibling"] = active.character_name
		save_data["health"] = active.current_health
		save_data["position"] = {
			"x": active.global_position.x,
			"y": active.global_position.y,
			"z": active.global_position.z
		}

	var json_str: String = JSON.stringify(save_data, "\t")
	var file := FileAccess.open(_save_file_path, FileAccess.WRITE)
	if file != null:
		file.store_string(json_str)
		file.close()

	if prompt_label != null:
		prompt_label.text = "บันทึกข้อมูลเรียบร้อยแล้ว!"
		var tween: Tween = create_tween()
		tween.tween_interval(2.0)
		tween.tween_callback(func():
			if _player_nearby != null and prompt_label != null:
				prompt_label.text = "[E] บันทึกความทรงจำ (เซฟเกม)"
		)

	game_saved.emit()
