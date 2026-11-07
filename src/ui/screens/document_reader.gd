class_name DocumentReader
extends CanvasLayer

## Classic Resident Evil style File/Document reader for Shadow of Lanna: Midnight Rite.
## Displays parchment documents, journals, and ancient manuscripts found during exploration.

signal document_opened(title: String)
signal document_closed()

@onready var control_root: Control = get_node_or_null("Control")
@onready var title_label: Label = get_node_or_null("Control/PaperPanel/TitleLabel")
@onready var content_label: Label = get_node_or_null("Control/PaperPanel/ScrollContainer/ContentLabel")

func _ready() -> void:
	if control_root != null:
		control_root.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if control_root != null and control_root.visible:
		if event.is_action_pressed("interact") or event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_E or event.keycode == KEY_ESCAPE or event.keycode == KEY_SPACE)):
			close_document()

## Opens and displays a document with the given title and text.
func open_document(doc_title: String, doc_content: String) -> void:
	if control_root != null:
		control_root.visible = true
	if title_label != null:
		title_label.text = doc_title
	if content_label != null:
		content_label.text = doc_content
	document_opened.emit(doc_title)

## Closes the document reader.
func close_document() -> void:
	if control_root != null:
		control_root.visible = false
	document_closed.emit()
