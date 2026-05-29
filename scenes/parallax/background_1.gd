extends Control

var speed_coef = 2.0


func _ready() -> void:
	get_viewport().size_changed.connect(_on_screen_resized)
	_on_screen_resized()
	update_speed()


func update_speed():
	for el in get_children():
		el.autoscroll *= speed_coef

var resize_coef = {"Sky": 1, "Mountains": 1, "Clouds": 1, "Bushes": 1, "Tree1": 1, "Tree2": 1, "Grass": 1, "Road": 1}

func _on_screen_resized() -> void:
	var view_size = get_viewport_rect().size
	
	for el in get_children():
		var parallax = el
		var sprite = el.get_child(0)
		
		if sprite and sprite.texture:
			var tex_size = sprite.texture.get_size()
			
			var scale_factor_x = (view_size.x / tex_size.x) * resize_coef[el.name]
			var scale_factor_y = (view_size.y / tex_size.y) * resize_coef[el.name]
			
			var final_scale = max(scale_factor_x, scale_factor_y)
			
			sprite.scale = Vector2(final_scale, final_scale)
			
			parallax.repeat_size.x = tex_size.x * final_scale


func _process(delta: float) -> void:
	if not GameManager.is_game_active:
		speed_coef = 0
		update_speed()
