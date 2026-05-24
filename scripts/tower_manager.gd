class_name TowerManager extends Node

const TOWER_BASE_PATH = "res://scenes/tower/TowerBase.tscn"
const TOWER_SECTION_PATH = "res://scenes/tower/TowerSection.tscn"

var tower_root: Node2D = null
var sections: Array = []
var tower_speed: float = 50
var start_x: float = 200
var start_y: float = 600
var player: Player

func _ready() -> void:
	add_to_group("tower_manager")

func build_tower(parent_node: Node2D, count: int = 3) -> void:
	tower_root = parent_node
	
	var base_scene = preload(TOWER_BASE_PATH)
	var base = base_scene.instantiate()
	base.position = Vector2(start_x, start_y)
	parent_node.add_child(base)
	sections.append(base)
	var last_section = base

	var section_scene = preload(TOWER_SECTION_PATH)
	for i in range(count):
		var section = section_scene.instantiate()
		var y_pos = last_section.position.y - last_section.get_height()
		section.position = Vector2(start_x, y_pos)
		section.destroyed.connect(handle_section_destroyed)
		
		parent_node.add_child(section)
		
		var joint = PinJoint2D.new()
		joint.position = Vector2(start_x, (last_section.position.y + section.position.y) / 2)
		joint.node_a = last_section.get_path()
		joint.node_b = section.get_path()
		section.add_child(joint)
		
		sections.append(section)
		last_section = section
		
	spawn_player_on_top()
	start_moving(tower_speed)

func start_moving(speed: float) -> void:
	for section in sections:
		if section.freeze:
			section.global_position.x += speed
		else:
			section.linear_velocity = Vector2(speed, 0)
			
		if section.has_method("start_wheels"):
			section.start_wheels(speed)

func spawn_player_on_top() -> void:
	if sections.is_empty(): return
	var top_section = sections[-1]
	var player_scene = preload("res://scenes/player/Player.tscn")
	player = player_scene.instantiate()
	
	top_section.add_child(player)
	
	var section_height = top_section.get_height()
	var player_height = player.get_node("Sprite2D").texture.get_height() * \
						player.get_node("Sprite2D").scale.y
						
	player.position = Vector2(0, -(section_height / 2) - (player_height / 2))

func handle_section_destroyed(destroyed_section: TowerSection) -> void:
	var destroyed_index = sections.find(destroyed_section)
	if destroyed_index == -1: return
	
	var upper_sections: Array = []
	for i in range(destroyed_index + 1, sections.size()):
		upper_sections.append(sections[i])
		
	sections.erase(destroyed_section)
	
	if player and player.get_parent() == destroyed_section:
		var new_top = sections[-1]
		var old_global_pos = player.global_position
		
		destroyed_section.remove_child(player)
		new_top.add_child(player)
		
		player.global_position = old_global_pos

	for upper_section in upper_sections:
		if upper_section is RigidBody2D:
			upper_section.freeze = false
			upper_section.sleeping = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var target_section = get_section_under_mouse()
		if target_section:
			target_section.destroy()

func get_section_under_mouse() -> TowerSection:
	var space_state = tower_root.get_world_2d().direct_space_state
	var mouse_pos = tower_root.get_global_mouse_position()
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_bodies = true
	
	var results = space_state.intersect_point(query)
	for result in results:
		var collider = result.collider
		if collider is TowerSection:
			return collider
	return null
	
func _physics_process(_delta: float) -> void:
	for section in sections:
		if is_instance_valid(section):
			if section.freeze:
				section.global_position.x = start_x
				if section is RigidBody2D:
					section.linear_velocity.x = 0.0
					section.angular_velocity = 0.0
