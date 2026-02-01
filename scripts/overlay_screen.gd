extends Control
class_name  overlay_screen

const VISIBLE_MODULATE = Color(1.0, 1.0, 1.0, 1.0)
const INVISIBLE_MODULATE =Color(1.0, 1.0, 1.0, 0)

func _ready() -> void:
	%InteractPrompt.visible = false
	%InteractPrompt.modulate = INVISIBLE_MODULATE
	%BackPrompt.visible = false
	%BackPrompt.modulate = INVISIBLE_MODULATE
	%SpeechBubble.visible = false
	%SpeechBubble.modulate = INVISIBLE_MODULATE

func change_interact_visibility(new_visibility: bool) -> void:
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	%InteractPrompt.visible = new_visibility
	tween.tween_property(%InteractPrompt, "modulate", VISIBLE_MODULATE if new_visibility else INVISIBLE_MODULATE, 0.5)

func change_back_visibility(new_visibility: bool) -> void:
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	%BackPrompt.visible = new_visibility
	tween.tween_property(%BackPrompt, "modulate", VISIBLE_MODULATE if new_visibility else INVISIBLE_MODULATE, 0.5)

func update_speech_bubble(new_text: String) -> void:
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	%SpeechBubble.visible = true if new_text else false
	tween.tween_property(%SpeechBubble, "modulate", VISIBLE_MODULATE if new_text else INVISIBLE_MODULATE, 0.5)
	%SpeechLabel.text = new_text
