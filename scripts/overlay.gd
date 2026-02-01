extends Control
class_name  overlay

const VISIBLE_MODULATE = Color(1.0, 1.0, 1.0, 1.0)
const INVISIBLE_MODULATE =Color(1.0, 1.0, 1.0, 0)

func _ready() -> void:
	%InteractPrompt.visible = false
	%BackPrompt.visible = false

func change_interact_visibility(new_visibility: bool) -> void:
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%InteractPrompt, "modulate", VISIBLE_MODULATE if new_visibility else INVISIBLE_MODULATE, 0.5)
	%InteractPrompt.visible = new_visibility

func change_back_visibility(new_visibility: bool) -> void:
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%BackPrompt, "modulate", VISIBLE_MODULATE if new_visibility else INVISIBLE_MODULATE, 0.5)
	%BackPrompt.visible = new_visibility

func update_speech_bubble(new_text: String) -> void:
	%SpeechLabel.text = new_text
