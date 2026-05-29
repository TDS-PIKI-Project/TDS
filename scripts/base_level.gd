class_name BaseLevel extends Node2D

@onready var post_game_menu: ColorRect = $CanvasLayer/PostGameMenu

@export var total_lanes: int = 5
@export var buffer_size: int = 1
@export var lane_height: float = 10.0
@export var start_y: float = 570.0
@export var lane_random_offset: float = 20.0   # максимальное отклонение по Y

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var enemy_scene: PackedScene = null
var player_scene: PackedScene = null
var tower_manager: TowerManager = null
var player: Node2D = null
var all_lanes = []
var spawn_lanes = []
var enemies_arr = []
var statistic_labels : Node
var gold_earned_this_run: int = 0
var score : int = 0
var enemies_killed_count: int = 0
var start_time_msec: float = 0.0
var final_survival_time: float = 0.0


const BASE_URL = "http://127.0.0.1:8000/submit_score"
@onready var http_request: HTTPRequest = HTTPRequest.new()

func _ready():
	setup_lanes()
	setup_level()
	
	tower_manager = TowerManager.new()
	add_child(tower_manager)
	tower_manager.build_tower(self)
	
	statistic_labels = load(Globals.STATISTICS_PATH).instantiate()
	add_child(statistic_labels)
	
	add_child(http_request)
	http_request.request_completed.connect(_on_score_submitted)

	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.5
	timer.timeout.connect(spawn_enemy)
	timer.autostart = true
	timer.start()
	
	start_time_msec = Time.get_ticks_msec()
	statistic_labels.updateGold()
	statistic_labels.setTimer()
	statistic_labels.updateTimer()
	
	if tower_manager.player:
		player = tower_manager.player
		
	GameManager.game_started.emit()

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
	enemies_arr.append(enemy)
	
	add_child(enemy)


func send_score_to_server(score_value: int) -> void:
	if not GameManager.is_logged_in():
		print("Ошибка: Пользователь не авторизован")
		return
	
	# Формируем JSON тело запроса согласно Pydantic-схеме ScoreSubmit
	var body = JSON.stringify({"score": score_value})
	
	# Формируем заголовки, включая Bearer токен авторизации
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + GameManager.auth_token
	]
	var error = http_request.request(BASE_URL, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("Ошибка инициализации запроса: ", error)

func _on_score_submitted(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.new()
		var parse_err = json.parse(body.get_string_from_utf8())
		
		if parse_err == OK:
			var response_data = json.get_data()
			print("Счет успешно обновлен!")
			if response_data.get("new_record") == true:
				post_game_menu.activate_new_record_animation()
	else:
		print("Ошибка сервера. Код ответа: ", response_code)
		print("Детали: ", body.get_string_from_utf8())


func _process(delta: float) -> void:
	#print("Игрок сейчас умер? ", player)
	if player != null and player._is_dead:
		if not GameManager.is_logged_in():
			return
		send_score_to_server(score)
		player.queue_free()
		player = null
		
		var current_time_msec = Time.get_ticks_msec()
		final_survival_time = (current_time_msec - start_time_msec) / 1000.0
		
		GameManager.save_progress_to_server()
		post_game_menu.show_game_over(score, enemies_killed_count, gold_earned_this_run, final_survival_time)
	
	if player == null or player._is_dead:
		return
		
	var new_arr = []
	for enemy in enemies_arr:
		if enemy._is_dead:
			enemies_killed_count += 1
			var coins_reward = 3 + (enemy.enemy_type * 2)
			GameManager.gold += coins_reward
			gold_earned_this_run += coins_reward
			statistic_labels.updateGold()
			
			score += 2 * enemy.enemy_type + 1
			statistic_labels.updateScore(score)
			enemy.queue_free()
		else:
			new_arr.append(enemy)
	enemies_arr = new_arr
	statistic_labels.updateTimer()
			
