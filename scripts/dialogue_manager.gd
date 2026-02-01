extends Node
class_name dialogue_manager

var current_dialogue: dialogue = null
var is_dialogue_active: bool = false
var overlay_scene: overlay_screen = null

signal dialogue_started
signal dialogue_ended
signal line_displayed(line: dialogue_line)

func _ready() -> void:
	overlay_scene = get_tree().get_first_node_in_group("OverlayScreen")
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if not is_dialogue_active or not current_dialogue:
		return
	
	# Accept any mouse button press or any key press
	var should_advance = false
	if event is InputEventMouseButton and event.pressed:
		should_advance = true
	elif event is InputEventKey and event.pressed and not event.echo:
		should_advance = true
	
	if should_advance:
		if not current_dialogue.advance():
			end_dialogue()
		else:
			_display_current_line()
		get_tree().get_root().set_input_as_handled()

func start_dialogue(dialogue_to_start: dialogue) -> void:
	if is_dialogue_active:
		return
	
	current_dialogue = dialogue_to_start
	current_dialogue.start()
	is_dialogue_active = true
	dialogue_started.emit()
	
	# Hide prompts when dialogue starts
	if overlay_scene:
		overlay_scene.change_interact_visibility(false)
		overlay_scene.change_back_visibility(false)
	
	_display_current_line()

func _display_current_line() -> void:
	var line = current_dialogue.get_current_line()
	if line:
		line_displayed.emit(line)
		if overlay_scene:
			overlay_scene.update_dialogue_bubble(line.speaker, line.text)

func end_dialogue() -> void:
	is_dialogue_active = false
	current_dialogue = null
	dialogue_ended.emit()
	if overlay_scene:
		overlay_scene.hide_dialogue_bubble()
		# Restore back prompt visibility after dialogue
		overlay_scene.change_back_visibility(true)

func is_in_dialogue() -> bool:
	return is_dialogue_active
