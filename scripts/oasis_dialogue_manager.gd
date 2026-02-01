extends OasisManager
class_name OasisDialogueManager

var is_dialogue_active: bool = false
var overlay_scene: overlay_screen = null
var current_traverser: OasisTraverser = null
var _waiting_for_response: bool = false
var _current_responses: Array[String] = []
var _ignore_input_until_release: bool = false

signal dialogue_started
signal dialogue_ended

func _ready() -> void:
	json_path = "res://assets/dialogue/dialogue.json"
	overlay_scene = get_tree().get_first_node_in_group("OverlayScreen")
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if not is_dialogue_active:
		return
	
	# Consume input release to prevent carry-over from previous state
	if _ignore_input_until_release:
		if event is InputEventKey and not event.pressed:
			_ignore_input_until_release = false
		elif event is InputEventMouseButton and not event.pressed:
			_ignore_input_until_release = false
		return
	
	if _waiting_for_response:
		# Handle response selection
		if event.is_action_pressed("response_one") and _current_responses.size() >= 1:
			select_response(0)
			get_tree().get_root().set_input_as_handled()
			return
		elif event.is_action_pressed("response_two") and _current_responses.size() >= 2:
			select_response(1)
			get_tree().get_root().set_input_as_handled()
			return
	else:
		# Accept any mouse button press or any key press to advance dialogue
		var should_advance = false
		if event is InputEventMouseButton and event.pressed:
			should_advance = true
		elif event is InputEventKey and event.pressed and not event.echo:
			should_advance = true
		
		if should_advance:
			advance_dialogue()
			get_tree().get_root().set_input_as_handled()
			# Set flag to ignore input until key/mouse is released
			_ignore_input_until_release = true

func advance_dialogue() -> void:
	if current_traverser and not _waiting_for_response:
		current_traverser.next()

func select_response(index: int) -> void:
	if not current_traverser or not _waiting_for_response:
		return
	
	if index < 0 or index >= _current_responses.size():
		print("return")
		return
	
	_waiting_for_response = false
	_current_responses.clear()
	
	# Select the response and continue
	current_traverser.next(index)

func is_in_dialogue() -> bool:
	return is_dialogue_active

func translate(key: String) -> String:
	return tr(key)

func validate_conditions(_traverser: OasisTraverser, _conditions: Array[OasisKeyValue]) -> bool:
	# No conditions for now - return true to allow all dialogue paths
	return true

func handle_actions(traverser: OasisTraverser, actions: Array[OasisKeyValue]) -> void:
	for action in actions:
		match action.key:
			"branch":
				# Handle branch transitions
				traverser.branch(action.value)
			_:
				push_warning("Unhandled action: %s" % action.key)

func start_dialogue(character: OasisCharacter) -> void:
	if is_dialogue_active:
		return
	
	_last_character = character
	current_traverser = character.start()
	if not current_traverser:
		push_error("Failed to start dialogue for character: %s" % character.character)
		return
	
	is_dialogue_active = true
	dialogue_started.emit()
	
	# Hide prompts when dialogue starts
	if overlay_scene:
		overlay_scene.change_interact_visibility(false)
		overlay_scene.change_back_visibility(false)
	
	# Connect to traverser signals
	current_traverser.prompt.connect(_on_prompt)
	current_traverser.responses.connect(_on_responses)
	current_traverser.finished.connect(_on_finished)

func _on_prompt(text: String) -> void:
	if overlay_scene:
		# Get the character name from the current dialogue
		var character_name = ""
		if current_traverser and current_traverser.get_current():
			character_name = _last_character.character if _last_character else ""
		overlay_scene.update_dialogue_bubble(character_name, text)

func _on_responses(items: Array[String]) -> void:
	if items.size() == 0:
		return
	
	_waiting_for_response = true
	_current_responses = items
	
	if overlay_scene:
		# Hide the continue prompt when showing responses
		if overlay_scene.has_node("%Prompt"):
			overlay_scene.get_node("%Prompt").visible = items.size() < 2
		
		# Show response choices (keep the main dialogue bubble visible)
		overlay_scene.show_responses(items)

func _on_finished() -> void:
	end_dialogue()

func end_dialogue() -> void:
	if current_traverser:
		current_traverser.prompt.disconnect(_on_prompt)
		current_traverser.responses.disconnect(_on_responses)
		current_traverser.finished.disconnect(_on_finished)
		current_traverser = null
	
	is_dialogue_active = false
	_waiting_for_response = false
	_current_responses.clear()
	dialogue_ended.emit()
	
	if overlay_scene:
		overlay_scene.hide_dialogue_bubble()
		overlay_scene.hide_responses()
		overlay_scene.change_back_visibility(true)
