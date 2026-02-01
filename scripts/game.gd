extends Node2D

var current_map: Node2D = null
var player: CharacterBody2D = null
var overlay: Control = null
var return_position: Vector2 = Vector2.ZERO
var previous_map: Node2D = null

func _ready() -> void:
	# Cache references to essential nodes
	player = get_node_or_null("Chomp")
	overlay = get_node_or_null("Overlay")
	current_map = get_node_or_null("Map")
	
	if player:
		player.game_manager = self
		# Spawn player at initial SpawnPoint
		var spawn_point = get_node_or_null("SpawnPoint")
		if spawn_point:
			player.global_position = spawn_point.global_position
	
	if overlay:
		overlay.visible = true

func load_map(scene: PackedScene, entry_position: Vector2 = Vector2.ZERO, boundary_name: String = "") -> void:
	if not scene:
		return
	
	# Store return information
	if current_map and player:
		return_position = player.global_position
		previous_map = current_map
	
	# Remove old map
	if current_map:
		remove_child(current_map)
		current_map.queue_free()
	
	# Load new map
	current_map = scene.instantiate()
	add_child(current_map)
	
	# Find SpawnPoint in the loaded scene
	var spawn_point = _find_spawn_point(current_map)
	var spawn_position = entry_position
	if spawn_point:
		spawn_position = spawn_point.global_position
	
	# Reorder nodes so player is on top
	if player:
		move_child(player, -1)
		player.global_position = spawn_position
		_update_player_boundary(boundary_name)
	
	if overlay:
		move_child(overlay, -1)
	
	# Show back button when in a land area
	if overlay:
		overlay.change_back_visibility(true)

func return_to_previous_map() -> void:
	if not previous_map:
		return
	
	# Remove current map
	if current_map:
		remove_child(current_map)
		current_map.queue_free()
	
	# Restore previous map
	current_map = previous_map
	add_child(current_map)
	previous_map = null
	
	# Restore player position
	if player:
		move_child(player, -1)
		player.global_position = return_position
		_update_player_boundary()
		player.is_in_land_area = false
	
	if overlay:
		move_child(overlay, -1)
		overlay.change_back_visibility(false)
		overlay.change_interact_visibility(false)

func _update_player_boundary(boundary_name: String = "") -> void:
	if not player or not current_map:
		return
	
	# If a specific boundary name is provided, use it
	if boundary_name != "":
		var boundary = current_map.get_node_or_null(boundary_name + "/CollisionPolygon2D")
		if not boundary:
			# Try without the /CollisionPolygon2D suffix (in case it's a direct path)
			boundary = current_map.get_node_or_null(boundary_name)
		if boundary and boundary is CollisionPolygon2D:
			player.collision_polygon = boundary.polygon
			return
	
	# Otherwise, try to find boundary collision polygons in the current map
	var boundary_np = current_map.get_node_or_null("BoundaryNP/CollisionPolygon2D")
	var boundary_p = current_map.get_node_or_null("BoundaryP/CollisionPolygon2D")
	
	if boundary_np and boundary_p:
		# Update player's collision polygon based on park accessibility
		player._update_boundary()
	elif boundary_np:
		# Only non-park boundary exists
		player.collision_polygon = boundary_np.polygon
	elif boundary_p:
		# Only park boundary exists
		player.collision_polygon = boundary_p.polygon
	# If no boundaries found, player keeps their current boundary

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
