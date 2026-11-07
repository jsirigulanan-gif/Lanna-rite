class_name TungPuzzle
extends Control

## Lanna Tung direction puzzle for Shadow of Lanna: Midnight Rite.
## Requires the player to input the correct 4-direction sequence based on the palm leaf manuscript.

signal puzzle_solved()
signal puzzle_failed()
signal puzzle_closed()

enum TungDirection {
	NORTH, # 0: ทิศเหนือ
	SOUTH, # 1: ทิศใต้
	EAST,  # 2: ทิศตะวันออก
	WEST,  # 3: ทิศตะวันตก
}

## Correct sequence based on the ancient palm leaf lore: North -> South -> East -> West
@export var correct_sequence: Array[int] = [
	TungDirection.NORTH,
	TungDirection.SOUTH,
	TungDirection.EAST,
	TungDirection.WEST,
]

var entered_sequence: Array[int] = []
var is_solved: bool = false

@onready var status_label: Label = get_node_or_null("Panel/StatusLabel")
@onready var sequence_display: Label = get_node_or_null("Panel/SequenceDisplay")

func _ready() -> void:
	visible = false
	_update_display()

## Opens the puzzle overlay.
func open_puzzle() -> void:
	if is_solved:
		return
	entered_sequence.clear()
	visible = true
	_update_display("โปรดระบุลำดับทิศทางของตุงอาคมตามคัมภีร์ใบลาน")

## Closes the puzzle overlay.
func close_puzzle() -> void:
	visible = false
	puzzle_closed.emit()

## Submits a direction symbol to the sequence.
func press_direction(direction_index: int) -> void:
	if is_solved or entered_sequence.size() >= 4:
		return

	entered_sequence.append(direction_index)
	_update_display()

	if entered_sequence.size() == correct_sequence.size():
		_evaluate_sequence()

func _evaluate_sequence() -> void:
	var matches: bool = true
	for i in range(correct_sequence.size()):
		if entered_sequence[i] != correct_sequence[i]:
			matches = false
			break

	if matches:
		is_solved = true
		_update_display("รหัสถูกต้อง! ยันต์อาคมคลายตัวแล้ว")
		puzzle_solved.emit()
		get_tree().create_timer(1.2).timeout.connect(close_puzzle)
	else:
		_update_display("รหัสไม่ถูกต้อง! ลมหวีดหวิวพัดตุงสะบัด")
		puzzle_failed.emit()
		get_tree().create_timer(1.0).timeout.connect(reset_sequence)

## Resets player's entered direction sequence.
func reset_sequence() -> void:
	if is_solved:
		return
	entered_sequence.clear()
	_update_display("ลำดับถูกรีเซ็ต โปรดลองใหม่อีกครั้ง")

func _update_display(custom_status: String = "") -> void:
	if status_label != null and not custom_status.is_empty():
		status_label.text = custom_status

	if sequence_display != null:
		var display_text: String = "ลำดับที่เลือก: "
		if entered_sequence.is_empty():
			display_text += "[ ยังไม่ได้เลือก ]"
		else:
			var parts: Array[String] = []
			for dir in entered_sequence:
				match dir:
					TungDirection.NORTH:
						parts.append("ทิศเหนือ (เปิ้น)")
					TungDirection.SOUTH:
						parts.append("ทิศใต้ (ก้ำ)")
					TungDirection.EAST:
						parts.append("ทิศตะวันออก (วันออก)")
					TungDirection.WEST:
						parts.append("ทิศตะวันตก (วันตก)")
			display_text += " -> ".join(parts)
		sequence_display.text = display_text
