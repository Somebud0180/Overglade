extends TextureButton

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	var game_manager = get_tree().get_first_node_in_group("Game")
	if game_manager and game_manager.has_method("return_to_previous_map"):
		game_manager.return_to_previous_map()
