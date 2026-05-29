extends Node

# ---  SIGNALS  ---
signal game_started
signal game_ended

# --- CONSTANTS ---

#const BASE_URL = "http://46.17.99.81:8000"
var BASE_URL = "http://127.0.0.1:8000" 

# --- VARIABLES ---

var auth_token: String = ""
var username: String = ""

var gold: int = 100
var score: int = 0
var is_game_active: bool = false

var floors: Array = [null, null, null]

@onready var save_http_client: HTTPRequest = HTTPRequest.new()

# --- FUNCTIONS ---

func _ready():
	if OS.has_feature("web"):
		BASE_URL = "https://tds-ea13.onrender.com"
	
	print("Игра подключена к серверу: ", BASE_URL)
	
	add_child(save_http_client)
	save_http_client.request_completed.connect(_on_save_completed)

func save_token(token: String):
	auth_token = token

func is_logged_in() -> bool:
	return auth_token != ""

func save_progress_to_server():
	if not is_logged_in():
		print("[Save] Error: Player is not registered, can't save progress.")
		return
		
	print("Saved money: ", gold)
		
	var save_data = {
		"gold": gold,
		"floor_1": floors[0],
		"floor_2": floors[1],
		"floor_3": floors[2],
	}
	
	var body = JSON.stringify(save_data)
	
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + auth_token
	]
	
	var err = save_http_client.request(BASE_URL + "/save_progress", \
	headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		print("[Save] Error with sending request: ", err)

func _on_save_completed(_result, response_code, _headers, _body):
	if response_code == 200:
		print("[Save] Прогресс успешно синхронизирован с БД!")
	else:
		print("[Save] Ошибка сохранения на сервере! Код ответа: ", response_code)

func reset_session():
	auth_token = ""
	username = ""
	gold = 100
	score = 0
	floors = [null, null, null]
