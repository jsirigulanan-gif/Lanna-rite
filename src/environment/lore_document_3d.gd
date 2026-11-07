class_name LoreDocument3D
extends Area3D

## Interactive 3D world document/file for Shadow of Lanna: Midnight Rite.
## When explored, opens the DocumentReader modal with deep story lore.

signal document_read()

@export var document_title: String = "บันทึกครูเวร"
@export_multiline var document_content: String = ""

var _player_nearby: PlayerSibling3D = null

@onready var prompt_label: Label3D = get_node_or_null("PromptLabel3D")

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
			read_document()

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerSibling3D:
		_player_nearby = body as PlayerSibling3D
		if prompt_label != null:
			prompt_label.text = "[E] อ่าน " + document_title
			prompt_label.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body == _player_nearby:
		_player_nearby = null
		if prompt_label != null:
			prompt_label.visible = false

func read_document() -> void:
	var reader: DocumentReader = get_tree().root.find_child("DocumentReader", true, false) as DocumentReader
	if reader != null:
		reader.open_document(document_title, document_content)
		document_read.emit()
