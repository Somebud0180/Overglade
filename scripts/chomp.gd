extends CharacterBody2D
class_name player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const CAMERA_SMOOTHING_PADDING = 0.1  # Time in seconds to allow camera to move instantly

var is_in_land_area: bool = false
var current_land_area: Area2D = null
var current_boundary: boundary_area = null
var game_manager: Node = null
var _camera_smoothing_timer: float = 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		# Skip interact if dialogue is active (let DialogueManager handle it)
		if DialogueManager.is_in_dialogue():
			return
		
		if is_in_land_area and current_land_area:
			if current_land_area.has_method("interact"):
				%Camera2D.position_smoothing_enabled = false
				_camera_smoothing_timer = CAMERA_SMOOTHING_PADDING
				current_land_area.interact()
	
	if event.is_action_pressed("back") or event.is_action_pressed("ui_cancel"):
		# Disable leaving map when in dialogue
		if DialogueManager.is_in_dialogue():
			return
		
		if game_manager and game_manager.has_method("return_to_previous_map"):
			%Camera2D.position_smoothing_enabled = false
			_camera_smoothing_timer = CAMERA_SMOOTHING_PADDING
			game_manager.return_to_previous_map()

func _physics_process(delta: float) -> void:	
	# Handle camera smoothing padding timer
	if _camera_smoothing_timer > 0:
		_camera_smoothing_timer -= delta
		if _camera_smoothing_timer <= 0:
			%Camera2D.position_smoothing_enabled = true
	
	# Check if dialogue is active - if so, disable player movement
	if DialogueManager.is_in_dialogue():
		velocity = Vector2.ZERO
		_update_sprite_on_velocity(velocity)
		return
	
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_direction:
		velocity = input_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 5)
		velocity.y = move_toward(velocity.y, 0, SPEED * delta * 5)
	
	_update_sprite_on_velocity(velocity)
	move_and_slide()
	
	# Confine player to boundary
	if current_boundary:
		_clamp_to_boundary()

func _update_sprite_on_velocity(new_velocity: Vector2) -> void:
	if abs(new_velocity.x) > 0 or abs(new_velocity.y) > 0:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("default")
	
	if new_velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif new_velocity.x < 0:
		$AnimatedSprite2D.flip_h = true

func find_current_boundary(current_map: Node2D) -> void:
	for child in current_map.get_children():
		if child is boundary_area and child.visible:
			current_boundary = child
			print(current_boundary)
			return

func _clamp_to_boundary() -> void:
	if not current_boundary:
		return
	
	# Get the collision polygon from the boundary Area2D
	var collision_polygon = current_boundary.get_node_or_null("CollisionPolygon2D")
	if not collision_polygon or not collision_polygon.polygon:
		return
	
	var polygon_points = collision_polygon.polygon
	var boundary_pos = current_boundary.global_position + collision_polygon.position
	
	# Check if player is inside the polygon
	if not Geometry2D.is_point_in_polygon(global_position - boundary_pos, polygon_points):
		# Find the closest point on the polygon boundary
		var closest_point = _get_closest_point_on_polygon(global_position - boundary_pos, polygon_points)
		global_position = boundary_pos + closest_point

func _get_closest_point_on_polygon(point: Vector2, polygon: PackedVector2Array) -> Vector2:
	var closest_point = polygon[0]
	var min_distance = point.distance_to(polygon[0])
	
	# Check each edge of the polygon
	for i in range(polygon.size()):
		var p1 = polygon[i]
		var p2 = polygon[(i + 1) % polygon.size()]
		
		# Find closest point on this edge
		var edge_point = _get_closest_point_on_segment(point, p1, p2)
		var distance = point.distance_to(edge_point)
		
		if distance < min_distance:
			min_distance = distance
			closest_point = edge_point
	
	return closest_point

func _get_closest_point_on_segment(point: Vector2, p1: Vector2, p2: Vector2) -> Vector2:
	var edge = p2 - p1
	var t = max(0.0, min(1.0, (point - p1).dot(edge) / edge.length_squared()))
	return p1 + t * edge

func enter_area(new_area: Area2D) -> void:
	if new_area is not land_area and new_area is not chat_area:
		return
	
	current_land_area = new_area
	is_in_land_area = true

func exit_area(new_area: Area2D) -> void:
	if new_area is not land_area and new_area is not chat_area:
		return
	
	if current_land_area == new_area:
		current_land_area = null
	is_in_land_area = false
