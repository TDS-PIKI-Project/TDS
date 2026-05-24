extends CharacterBody2D
class_name BaseEnemy

@export var speed: float = 150.0
@export var push_force: float = 10.0
@export var lane_attraction: float = 2.0 
@export var collision_radius_multiplier: float = 0.9
@export var push_x_strength: float = 1.5
@export var push_y_strength: float = 1.0
@export var velocity_lerp_speed: float = 0.1
var lane_clamp_offset: float # changed by level

var target_lane_y: float = 0.0
var all_lanes: Array = []
var neighbours: Array = []

var collision_shape: CollisionShape2D = null
var detector_area: Area2D = null

func _ready():
	add_to_group("enemies")
	
	if has_node("CollisionShape2D"):
		collision_shape = $CollisionShape2D
	if has_node("DetectorArea"):
		detector_area = $DetectorArea
		if not detector_area.body_entered.is_connected(_on_detector_body_entered):
			detector_area.body_entered.connect(_on_detector_body_entered)
		if not detector_area.body_exited.is_connected(_on_detector_body_exited):
			detector_area.body_exited.connect(_on_detector_body_exited)
	
func get_physic_colision_size():
	if collision_shape == null or collision_shape.shape == null:
		return 0.0
	if collision_shape.shape is RectangleShape2D:
		var rect = collision_shape.shape.get_rect()
		return max(rect.size.x, rect.size.y)
	elif collision_shape.shape is CircleShape2D:
		var radius = collision_shape.shape.radius
		return radius * 2.0
	else:
		assert(false, "What is the shape of collision??? Change it to either 
		rectangle or circle.")
		return 0.0

func _physics_process(_delta):
	var push_vector = Vector2.ZERO
	var radius = get_physic_colision_size() * collision_radius_multiplier
	
	for other in neighbours:
		if other == self:
			continue
		
		var dist = global_position.distance_to(other.global_position)
		if dist < radius:	
			var diff = global_position - other.global_position
			push_vector.x += diff.normalized().x * (radius - dist) * push_x_strength
			push_vector.y += diff.normalized().y * (radius - dist) * push_y_strength

	var target_velocity = Vector2(-speed, 0) + push_vector * push_force
	
	var dynamic_wall_x : float = get_tower_wall_x() + 3
	
	if dynamic_wall_x > 0.0 and global_position.x <= dynamic_wall_x:
		if target_velocity.x < 0:
			target_velocity.x = 0
		global_position.x = dynamic_wall_x
	
	if not all_lanes.is_empty():
		for lane_y in all_lanes:
			if abs(global_position.y - lane_y) < abs(global_position.y - target_lane_y):
				target_lane_y = lane_y

	target_velocity.y += (target_lane_y - global_position.y) * lane_attraction
	
	velocity = velocity.lerp(target_velocity, velocity_lerp_speed)
	move_and_slide()

	#if not all_lanes.is_empty():
		#global_position.y = clamp(global_position.y, all_lanes.min() - lane_clamp_offset,
		#all_lanes.max() + lane_clamp_offset)


func take_damage(amount: int):
	queue_free() 

func _on_detector_body_entered(body: Node2D) -> void:
	if body != self and body.is_in_group("enemies"):
		neighbours.append(body)

func _on_detector_body_exited(body: Node2D) -> void:
	if body != self and body.is_in_group("enemies"):
		if body in neighbours:
			neighbours.erase(body)

func get_tower_wall_x() -> float:
	var tower_manager = get_tree().get_first_node_in_group("tower_manager")
	var player_node = get_tree().get_first_node_in_group("player")
	
	if player_node == null or not is_instance_valid(player_node):
		return 0.0
		
	var enemy_half_width = get_physic_colision_size() / 2.0
	
	if tower_manager and not tower_manager.sections.is_empty():
		if tower_manager.sections.size() > 1:
			var section_block = tower_manager.sections[1]
			if is_instance_valid(section_block):
				var sprite = section_block.get_node_or_null("box")
				if sprite and sprite.texture:
					var half_width = (sprite.texture.get_width() * \
					 sprite.scale.x * section_block.scale.x) / 2.0
					return section_block.global_position.x + half_width + enemy_half_width
		
		if player_node != null and is_instance_valid(player_node):
			var player_sprite = player_node.get_node_or_null("Sprite2D")
			var p_half_width = 0.0
			
			if player_sprite and player_sprite.texture:
				p_half_width = (player_sprite.texture.get_width() * \
				 player_sprite.scale.x * player_node.scale.x) / 2.0
			
			return player_node.global_position.x + p_half_width + enemy_half_width
			
	assert(false, "How? check condidtions in get_tower_wall_x.")
	return 0.0
