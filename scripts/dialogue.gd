extends Resource
class_name dialogue

@export var dialogue_lines: Array[dialogue_line] = []
@export var npc_name: String = ""

var _current_line_index: int = 0

func _init(p_npc_name: String = "", p_lines: Array[dialogue_line] = []) -> void:
	npc_name = p_npc_name
	dialogue_lines = p_lines
	_current_line_index = 0

func start() -> void:
	_current_line_index = 0

func get_current_line() -> dialogue_line:
	if _current_line_index < dialogue_lines.size():
		return dialogue_lines[_current_line_index]
	return null

func advance() -> bool:
	_current_line_index += 1
	return _current_line_index < dialogue_lines.size()

func is_finished() -> bool:
	return _current_line_index >= dialogue_lines.size()

func reset() -> void:
	_current_line_index = 0
