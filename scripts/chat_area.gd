extends Area2D
class_name chat_area

@export var npc_name: String = "NPC"
@export var dialogue_lines: Array[String] = []

var overlay_scene: overlay_screen = null
var _dialogue: dialogue = null

func _ready() -> void:
	overlay_scene = get_tree().get_first_node_in_group("OverlayScreen")
	print("Chat area '%s' ready. OverlayScene found: %s" % [name, overlay_scene != null])
	
	# Create dialogue from exported lines if no dialogue_manager exists
	if dialogue_lines.size() > 0:
		_create_dialogue_from_lines()
		print("Chat area ready. Dialogue created with %d lines" % dialogue_lines.size())
	else:
		print("Chat area ready. No dialogue lines exported!")
	
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	print("Chat area signals connected for: %s" % name)

func _on_body_entered(body: Node) -> void:
	print("chat_area body_entered: %s" % body.name)
	if body is player:
		print("Player entered chat_area '%s'" % name)
		# Register with player like land_area does
		body.enter_area(self)
		if overlay_scene:
			overlay_scene.change_interact_visibility(true)
			print("Interact visibility set to true")
		else:
			print("ERROR: overlay_scene is null!")

func _on_body_exited(body: Node) -> void:
	print("chat_area body_exited: %s" % body.name)
	if body is player:
		# Unregister with player like land_area does
		body.exit_area(self)
		if overlay_scene:
			overlay_scene.change_interact_visibility(false)

func interact() -> void:
	if not _dialogue:
		return
	
	if DialogueManager.is_in_dialogue():
		return
	
	DialogueManager.start_dialogue(_dialogue)

func _create_dialogue_from_lines() -> void:
	var lines: Array[dialogue_line] = []
	for line_text in dialogue_lines:
		lines.append(dialogue_line.new(npc_name, line_text))
	_dialogue = dialogue.new(npc_name, lines)
