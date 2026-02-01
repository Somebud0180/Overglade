extends Control
class_name  loading_screen

const VISIBLE_MODULATE = Color(1.0, 1.0, 1.0, 1.0)
const INVISIBLE_MODULATE =Color(1.0, 1.0, 1.0, 0)

func _ready() -> void:
	visible = false

func change_interact_visibility(new_visibility: bool) -> void:
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	visible = new_visibility
	tween.tween_property(self, "modulate", VISIBLE_MODULATE if new_visibility else INVISIBLE_MODULATE, 0.5)
