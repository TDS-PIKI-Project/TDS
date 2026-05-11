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
	#if not has_node("DetectorArea"):
		#neighbours = get_tree().get_nodes_in_group("enemies")
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
	
	if not all_lanes.is_empty():
		for lane_y in all_lanes:
			if abs(global_position.y - lane_y) < abs(global_position.y - target_lane_y):
				target_lane_y = lane_y

	target_velocity.y += (target_lane_y - global_position.y) * lane_attraction
	
	velocity = velocity.lerp(target_velocity, velocity_lerp_speed)
	move_and_slide()

	if not all_lanes.is_empty():
		global_position.y = clamp(global_position.y, all_lanes.min() - lane_clamp_offset,
		all_lanes.max() + lane_clamp_offset)


func take_damage(amount: int):
	queue_free() 

func _on_detector_body_entered(body: Node2D) -> void:
	if body != self and body.is_in_group("enemies"):
		neighbours.append(body)

func _on_detector_body_exited(body: Node2D) -> void:
	if body != self and body.is_in_group("enemies"):
		if body in neighbours:
			neighbours.erase(body)
