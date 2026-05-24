class_name BaseLevel extends Node2D

@export var total_lanes: int = 15
@export var buffer_size: int = 1
@export var lane_height: float = 10.0
@export var start_y: float = 250.0
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

func spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()  # одна сцена для всех типов
	var lane_y: float = spawn_lanes.pick_random()
	var offset: float = _rng.randf_range(-lane_random_offset, lane_random_offset)

	# Случайный тип — enemy_type должен быть задан ДО add_child (до _ready)
	enemy.enemy_type    = Globals.EnemyType.values().pick_random()
	enemy.position      = Vector2(1200, lane_y + offset)
	enemy.target_lane_y = lane_y

	add_child(enemy)
