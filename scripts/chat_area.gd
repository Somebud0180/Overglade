extends Area2D
class_name chat_area

@export var area_name: String = ""
@export var npc_name: String = "NPC"

var overlay_scene: overlay_screen = null
var _oasis_character: OasisCharacter = nThull

func _ready() -> void:
	overlay_scene = get_tree().get_first_node_in_group("OverlayScreen")
	print("Chat area '%s' ready. OverlayScene found: %s" % [name, overlay_scene != null])
	
	# Create OasisCharacter for this NPC
	_oasis_character = OasisCharacter.new()
	_oasis_character.character = npc_name.to_lower()
	_oasis_character.root = 0
	add_child(_oasis_character)
	print("Chat area ready. OasisCharacter created for: %s" % npc_name)
	
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
			if area_name:
				overlay_scene.show_area_name(area_name)
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
			overlay_scene.hide_area_name()

func interact() -> void:
	if not _oasis_character:
		return
	
	if DialogueManager.is_in_dialogue():
		return
	
	DialogueManager.start_dialogue(_oasis_character)
