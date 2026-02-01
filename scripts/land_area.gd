extends Area2D
class_name land_area

@export var destination_scene: PackedScene
@export var destination_name: String
@export var entry_position: Vector2 = Vector2(640, 360)  # Default center position
@export var boundary_name: String = ""  # Name of boundary node to use (e.g., "BoundaryNP", "BoundaryP", or "Area2D")
var overlay: overlay

func _ready() -> void:
	overlay = get_tree().get_first_node_in_group("Overlay")
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func interact() -> void:
	if not destination_scene:
		return
	
	# Get the game manager and load the destination map
	var game_manager = get_node_or_null("/root/Game")
	if not game_manager:
		# Try to find it in parent tree
		var current = get_parent()
		while current:
			if current.has_method("load_map"):
				game_manager = current
				break
			current = current.get_parent()
	
	if game_manager and game_manager.has_method("load_map"):
		game_manager.load_map(destination_scene, entry_position, boundary_name)

func _on_body_entered(body: Node) -> void:
	if body is player:
		body.enter_area(self)
		if overlay:
			overlay.change_interact_visibility(true)

func _on_body_exited(body: Node) -> void:
	if body is player:
		body.exit_area(self)
		if overlay:
			overlay.change_interact_visibility(false)
