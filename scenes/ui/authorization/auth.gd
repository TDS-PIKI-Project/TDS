extends Control

@onready var login_box = $FormContainer/MarginContainer/MainVBox/LoginBox
@onready var register_box = $FormContainer/MarginContainer/MainVBox/RegisterBox
@onready var status_label = $FormContainer/MarginContainer/MainVBox/StatusLabel
@onready var http_request = $HTTPRequest

@onready var l_user = $FormContainer/MarginContainer/MainVBox/LoginBox/LUserEdit
@onready var l_pass = $FormContainer/MarginContainer/MainVBox/LoginBox/LPassEdit
@onready var r_user = $FormContainer/MarginContainer/MainVBox/RegisterBox/RUserEdit
@onready var r_pass = $FormContainer/MarginContainer/MainVBox/RegisterBox/RPassEdit

enum RequestMode { IDLE, LOGIN, REGISTER, FETCH_PROFILE }
var current_mode = RequestMode.IDLE

func _ready():
	$FormContainer/MarginContainer/MainVBox/LoginBox/LoginBtn.pressed.connect(_on_login_pressed)
	$FormContainer/MarginContainer/MainVBox/RegisterBox/RegisterBtn.pressed.connect(_on_register_pressed)
	$FormContainer/MarginContainer/MainVBox/LoginBox/ToRegisterBtn.pressed.connect(_switch_to_register)
	$FormContainer/MarginContainer/MainVBox/RegisterBox/ToLoginBtn.pressed.connect(_switch_to_login)
	
	http_request.request_completed.connect(_on_request_completed)

func _switch_to_register():
	login_box.hide()
	register_box.show()
	status_label.text = ""

func _switch_to_login():
	register_box.hide()
	login_box.show()
	status_label.text = ""

func _on_login_pressed():
	if l_user.text.is_empty() or l_pass.text.is_empty():
		_show_status("Введите данные!", Color.RED)
		return
	
	var body = "username=%s&password=%s" % [l_user.text.uri_encode(), l_pass.text.uri_encode()]
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	
	current_mode = RequestMode.LOGIN
	http_request.request(GameManager.BASE_URL + "/login", headers, HTTPClient.METHOD_POST, body)
	_show_status("Вход в систему...", Color.YELLOW)

func _on_register_pressed():
	if r_user.text.length() < 3:
		_show_status("Логин слишком короткий", Color.RED)
		return
		
	var body = JSON.stringify({"username": r_user.text, "password": r_pass.text})
	var headers = ["Content-Type: application/json"]
	
	current_mode = RequestMode.REGISTER
	http_request.request(GameManager.BASE_URL + "/register", headers, HTTPClient.METHOD_POST, body)
	_show_status("Регистрация...", Color.YELLOW)

func _fetch_profile_data():
	if GameManager.auth_token.is_empty():
		_show_status("Ошибка: Токен отсутствует!", Color.RED)
		return
		
	var headers = ["Authorization: Bearer " + GameManager.auth_token]
	current_mode = RequestMode.FETCH_PROFILE
	
	http_request.request(GameManager.BASE_URL + "/me", headers, HTTPClient.METHOD_GET)
	_show_status("Загрузка данных башни...", Color.YELLOW)


func _on_request_completed(_result, response_code, _headers, body):
	var response_text = body.get_string_from_utf8()
	
	if response_code != 200:
		current_mode = RequestMode.IDLE
		var response = JSON.parse_string(response_text)
		if response and response.has("detail"):
			_show_status(str(response["detail"]), Color.RED)
		else:
			_show_status("Ошибка сервера: " + str(response_code), Color.RED)
		return

	var response = JSON.parse_string(response_text)
	if response == null:
		_show_status("Ошибка разбора JSON", Color.RED)
		return

	match current_mode:
		RequestMode.LOGIN:
			if response.has("access_token"):
				GameManager.auth_token = response["access_token"]
				GameManager.username = l_user.text
				
				_fetch_profile_data()
			else:
				_show_status("Сервер не вернул токен авторизации", Color.RED)
		
		RequestMode.REGISTER:
			_show_status("Регистрация успешна! Войдите.", Color.GREEN)
			_switch_to_login()
			current_mode = RequestMode.IDLE
			
		RequestMode.FETCH_PROFILE:
			GameManager.gold = response.get("gold", 100)
			GameManager.score = response.get("score", 0)
			
			GameManager.floors[0] = response.get("floor_1")
			GameManager.floors[1] = response.get("floor_2")
			GameManager.floors[2] = response.get("floor_3")
			
			_show_status("Данные загружены! Запуск...", Color.GREEN)
			current_mode = RequestMode.IDLE
			
			Globals.change_level(Globals.MAIN_MENU_PATH) 

func _show_status(text: String, color: Color):
	status_label.text = text
	status_label.modulate = color
