extends Node2D

var current_map: Node2D = null
var player_node: player = null
var overlay_scene: overlay_screen = null
var loading_scene: loading_screen = null
var return_position: Vector2 = Vector2.ZERO
var previous_map: Node2D = null

func _ready() -> void:
	# Cache references to essential nodes
	player_node = get_node_or_null("Chomp")
	overlay_scene = get_tree().get_first_node_in_group("OverlayScreen")
	loading_scene = get_tree().get_first_node_in_group("LoadingScreen")
	current_map = get_node_or_null("Map")
	
	if player_node:
		player_node.game_manager = self
		player_node.find_current_boundary(current_map)
		# Spawn player_node at initial SpawnPoint
		var spawn_point = get_node_or_null("SpawnPoint")
		if spawn_point:
			player_node.global_position = spawn_point.global_position
	
	if overlay_scene:
		overlay_scene.visible = true
		# Show the letter at game start
		overlay_scene._show_letter()

func load_map(scene: PackedScene, entry_position: Vector2 = Vector2.ZERO, boundary_name: String = "") -> void:
	if not scene:
		return
	
	# Use fade transition if loading screen is available
	if loading_scene:
		await loading_scene.fade_transition(func():
			_perform_map_load(scene, entry_position, boundary_name)
		)
	else:
		_perform_map_load(scene, entry_position, boundary_name)

func _perform_map_load(scene: PackedScene, entry_position: Vector2, boundary_name: String) -> void:
	# Store return information and hide current map
	if current_map and player_node:
		return_position = player_node.global_position
		previous_map = current_map
		current_map.visible = false
	
	# Load new map
	current_map = scene.instantiate()
	add_child(current_map)
	
	# Find SpawnPoint in the loaded scene
	var spawn_point = _find_spawn_point(current_map)
	var spawn_position = entry_position
	if spawn_point:
		spawn_position = spawn_point.global_position
	
	# Reorder nodes so player_node is on top
	if player_node:
		move_child(player_node, -1)
		player_node.global_position = spawn_position
		player_node.find_current_boundary(current_map)
	
	# Show back button when in a land area
	if overlay_scene:
		overlay_scene.change_back_visibility(true)

func return_to_previous_map() -> void:
	if not previous_map:
		return
	
	# Use fade transition if loading screen is available
	if loading_scene:
		await loading_scene.fade_transition(func():
			_perform_return_to_previous_map()
		)
	else:
		_perform_return_to_previous_map()

func _perform_return_to_previous_map() -> void:
	# Remove current map
	if current_map:
		remove_child(current_map)
		current_map.queue_free()
	
	# Restore previous map
	current_map = previous_map
	add_child(current_map)
	previous_map = null
	
	# Restore player_node position
	current_map.visible = true
	move_child(player_node, -1)
	player_node.global_position = return_position
	_update_player_boundary()
	player_node.is_in_land_area = false
	
	if overlay_scene:
		move_child(overlay_scene, -1)
		overlay_scene.change_back_visibility(false)
		overlay_scene.change_interact_visibility(false)

func _update_player_boundary() -> void:
	if not player_node or not current_map:
		return
	
	player_node.find_current_boundary(current_map)

func _find_spawn_point(node: Node) -> Marker2D:
	# First check if the node itself is a SpawnPoint
	if node is Marker2D and node.name == "SpawnPoint":
		return node
	
	# Recursively search children
	for child in node.get_children():
		if child is Marker2D and child.name == "SpawnPoint":
			return child
		var result = _find_spawn_point(child)
		if result:
			return result
	
	return null
