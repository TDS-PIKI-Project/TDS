class_name BaseLevel extends Node2D

@export var total_lanes: int = 5
@export var buffer_size: int = 1
@export var lane_height: float = 10.0
@export var start_y: float = 500.0
@export var lane_random_offset: float = 20.0   # максимальное отклонение по Y

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var enemy_scene: PackedScene = null
var player_scene: PackedScene = null
var player: Node2D = null
var all_lanes = []
var spawn_lanes = []

func _ready():
	setup_lanes()
	setup_level()
	
	if player_scene != null:
		player = player_scene.instantiate()
		player.position = Vector2(150, 300)
		add_child(player)
	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.5
	timer.timeout.connect(spawn_enemy)
	timer.autostart = true
	timer.start()

func setup_lanes():
	all_lanes.clear()
	spawn_lanes.clear()
	
	for i in range(total_lanes):
		var y_pos = start_y + (i * lane_height)
		all_lanes.append(y_pos)
		
		if i >= buffer_size and i < (total_lanes - buffer_size):
			spawn_lanes.append(y_pos)

func setup_level():
	assert(false, "setup_level() must be overriden in the child class!")

func spawn_enemy():
	if enemy_scene == null:
		assert(false, "Error: enemy_scene is null! Set it in the child script or Inspector.")
		return
	var enemy = enemy_scene.instantiate()
	var start_lane = spawn_lanes.pick_random()
	var random_offset = 0
	
	enemy.enemy_type    = Globals.EnemyType.values().pick_random()
	enemy.position      = Vector2(1200, start_lane + random_offset)
	enemy.all_lanes = all_lanes
	enemy.target_lane_y = start_lane
	enemy.lane_clamp_offset = lane_height
	
	add_child(enemy)
