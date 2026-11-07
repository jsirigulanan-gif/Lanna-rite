class_name MainLevel
extends Node2D

## Main gameplay level for Shadow of Lanna: Midnight Rite.
## Integrates all 6 core systems into a playable survival horror loop.

@onready var game_manager: GameManager = $GameManager
@onready var escape_gate: Area2D = $Environment/EscapeGate
@onready var escape_label: Label = $Environment/EscapeGate/PromptLabel

func _ready() -> void:
	if escape_gate != null:
		escape_gate.body_entered.connect(_on_escape_gate_body_entered)
	if escape_label != null:
		escape_label.visible = false

func _on_escape_gate_body_entered(body: Node2D) -> void:
	if body is PlayerSibling:
		if game_manager != null and game_manager.is_altar_cleansed:
			game_manager.trigger_victory()
		elif escape_label != null:
			escape_label.text = "ประตูรั้วลงอาคมหนาแน่น! ต้องไปดับไฟที่แท่นบูชายัญก่อนจึงจะเปิดได้!"
			escape_label.visible = true
			get_tree().create_timer(3.0).timeout.connect(func():
				if escape_label != null:
					escape_label.visible = false
			)
