extends Control
class_name  overlay_screen

const VISIBLE_MODULATE = Color(1.0, 1.0, 1.0, 1.0)
const INVISIBLE_MODULATE =Color(1.0, 1.0, 1.0, 0)

signal response_selected(index: int)

func _ready() -> void:
	%InteractPrompt.visible = false
	%InteractPrompt.modulate = INVISIBLE_MODULATE
	%BackPrompt.visible = false
	%BackPrompt.modulate = INVISIBLE_MODULATE
	%SpeechBubble.visible = false
	%SpeechBubble.modulate = INVISIBLE_MODULATE
	%GradientBackground.visible = false
	%GradientBackground.modulate = INVISIBLE_MODULATE
	%AreaLabel.visible = false
	%AreaLabel.modulate = INVISIBLE_MODULATE
	
	# Hide continue prompt initially
	if has_node("%Prompt"):
		%Prompt.visible = false
	
	# Initialize response containers
	if has_node("%ResponseMarginContainer"):
		%ResponseMarginContainer.visible = false
		%ResponseMarginContainer.modulate = INVISIBLE_MODULATE
	
	# Hide individual response boxes initially
	if has_node("%Response1"):
		%Response1.visible = false
		%Response1.gui_input.connect(_on_response1_clicked)
	if has_node("%Response2"):
		%Response2.visible = false
		%Response2.gui_input.connect(_on_response2_clicked)
	
	# Make SpeechBubble clickable to advance dialogue
	if has_node("%SpeechBubble"):
		%SpeechBubble.gui_input.connect(_on_speech_bubble_clicked)

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
	print("Updating Text")

func update_dialogue_bubble(speaker: String, text: String) -> void:
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	# Show dialogue bubble
	%SpeechBubble.visible = true
	
	# Show continue prompt
	if has_node("%Prompt"):
		%Prompt.visible = true
	
	# Format and update the speech label
	var display_text = text
	if speaker:
		display_text = speaker + ": " + text
	%SpeechLabel.text = display_text
	
	# Also try individual speaker/text nodes if they exist
	if has_node("%DialogueSpeaker"):
		%DialogueSpeaker.text = speaker
	if has_node("%DialogueText"):
		%DialogueText.text = text
	
	# Fade in
	tween.tween_property(%SpeechBubble, "modulate", VISIBLE_MODULATE, 0.3)

func hide_dialogue_bubble() -> void:
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%SpeechBubble, "modulate", INVISIBLE_MODULATE, 0.3)
	await tween.finished
	%SpeechBubble.visible = false
	%SpeechLabel.text = ""
	
	# Hide continue prompt
	if has_node("%Prompt"):
		%Prompt.visible = false
	
	if has_node("%DialogueSpeaker"):
		%DialogueSpeaker.text = ""
	if has_node("%DialogueText"):
		%DialogueText.text = ""

func show_area_name(name_text: String) -> void:
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	%AreaLabel.visible = true
	%GradientBackground.visible = true
	%AreaLabel.text = name_text
	# Fade in label and gradient
	tween.tween_property(%AreaLabel, "modulate", VISIBLE_MODULATE, 0.3)
	get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).tween_property(%GradientBackground, "modulate", Color(1.0, 1.0, 1.0, 0.5), 0.3)

func hide_area_name() -> void:
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%AreaLabel, "modulate", INVISIBLE_MODULATE, 0.3)
	get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).tween_property(%GradientBackground, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.3)
	await tween.finished
	%AreaLabel.visible = false
	%GradientBackground.visible = false
	%AreaLabel.text = ""

func show_responses(responses: Array[String]) -> void:
	if not has_node("%ResponseMarginContainer"):
		return
	
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	%ResponseMarginContainer.visible = true
	
	# Update response text
	if has_node("%Response1") and responses.size() >= 1:
		%Response1.visible = true
		var label = %Response1.get_node("SpeechLabel")
		if label:
			# Don't show key prefix for single response
			if responses.size() == 1:
				label.text = responses[0]
			else:
				label.text = "[Q] " + responses[0]
	else:
		if has_node("%Response1"):
			%Response1.visible = false
	
	if has_node("%Response2") and responses.size() >= 2:
		%Response2.visible = true
		var label = %Response2.get_node("SpeechLabel")
		if label:
			label.text = "[E] " + responses[1]
	else:
		if has_node("%Response2"):
			%Response2.visible = false
	
	# Fade in
	tween.tween_property(%ResponseMarginContainer, "modulate", VISIBLE_MODULATE, 0.3)

func hide_responses() -> void:
	if not has_node("%ResponseMarginContainer"):
		return
	
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%ResponseMarginContainer, "modulate", INVISIBLE_MODULATE, 0.3)
	await tween.finished
	%ResponseMarginContainer.visible = false

func _show_letter() -> void:
	if has_node("%Letter"):
		var letter_node = %Letter
		letter_node.visible = true
		
		# Get the OasisCharacter and start the dialogue
		var oasis_character = %OasisCharacter
		DialogueManager.start_dialogue(oasis_character)
		_hide_letter()

func _hide_letter() -> void:
	await DialogueManager.dialogue_ended
	if has_node("%Letter"):
		var letter_node = %Letter
		letter_node.visible = false

func _on_response1_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if DialogueManager and DialogueManager.is_in_dialogue():
			DialogueManager.select_response(0)

func _on_response2_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if DialogueManager and DialogueManager.is_in_dialogue():
			DialogueManager.select_response(1)

func _on_speech_bubble_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if DialogueManager and DialogueManager.is_in_dialogue() and not DialogueManager._waiting_for_response:
			DialogueManager.advance_dialogue()
