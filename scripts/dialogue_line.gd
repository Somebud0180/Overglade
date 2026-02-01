extends Resource
class_name dialogue_line

@export var speaker: String = ""
@export var text: String = ""

func _init(p_speaker: String = "", p_text: String = "") -> void:
	speaker = p_speaker
	text = p_text
