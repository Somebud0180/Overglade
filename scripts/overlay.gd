extends Control
class_name  overlay

func _ready() -> void:
	$MarginContainer/InteractPrompt.visible = false
	$MarginContainer/BackPrompt.visible = false

func change_interact_visibility(new_visibility: bool) -> void:
	$MarginContainer/InteractPrompt.visible = new_visibility

func change_back_visibility(new_visibility: bool) -> void:
	$MarginContainer/BackPrompt.visible = new_visibility
