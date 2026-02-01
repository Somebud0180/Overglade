extends CharacterBody2D
class_name player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var collision_polygon: PackedVector2Array

var is_park_accessible: bool = false:
	set(value):
		is_park_accessible = value
		_update_boundary()

var is_in_land_area: bool = false
var current_land_area: Area2D = null
var game_manager: Node = null

func _ready() -> void:
	_update_boundary()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if is_in_land_area and current_land_area:
			if current_land_area.has_method("interact"):
				current_land_area.interact()
	
	if event.is_action_pressed("ui_cancel"):  # ESC or back button
		if game_manager and game_manager.has_method("return_to_previous_map"):
			game_manager.return_to_previous_map()

func _physics_process(delta: float) -> void:	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var new_velocity: Vector2
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_direction:
		new_velocity = input_direction * SPEED
	else:
		new_velocity.x = move_toward(velocity.x, 0, SPEED)
		new_velocity.y = move_toward(velocity.y, 0, SPEED)
	
	var test_position = global_position + new_velocity * delta
	
	if Geometry2D.is_point_in_polygon(test_position, collision_polygon):
		global_position = test_position
		_update_sprite_on_velocity(new_velocity)
	else:
		_update_sprite_on_velocity(Vector2(0,0))
	
	move_and_slide()

func _update_boundary() -> void:
	var boundary_p = get_node_or_null("../Map/BoundaryP/CollisionPolygon2D")
	var boundary_np = get_node_or_null("../Map/BoundaryNP/CollisionPolygon2D")
	
	if is_park_accessible and boundary_p:
		collision_polygon = boundary_p.polygon
	elif boundary_np:
		collision_polygon = boundary_np.polygon
	elif boundary_p:
		collision_polygon = boundary_p.polygon

func _update_sprite_on_velocity(new_velocity: Vector2) -> void:
	if abs(new_velocity.x) > 0 or abs(new_velocity.y) > 0:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("default")
	
	if new_velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif new_velocity.x < 0:
		$AnimatedSprite2D.flip_h = true

func enter_area(new_area: Area2D) -> void:
	if new_area is not land_area:
		return
	
	current_land_area = new_area
	is_in_land_area = true

func exit_area(new_area: Area2D) -> void:
	if new_area is not land_area:
		return
	
	if current_land_area == new_area:
		current_land_area = null
	is_in_land_area = false
