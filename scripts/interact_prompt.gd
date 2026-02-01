extends TextureButton

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	var _player = get_tree().get_first_node_in_group("Player")
	if _player and _player.is_in_land_area and _player.current_land_area:
		if _player.current_land_area.has_method("interact"):
			_player.current_land_area.interact()
