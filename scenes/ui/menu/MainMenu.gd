class_name MainMenu extends Control

@onready var shop_page = $MainLayout/ContentArea/ContentVBox/PageContainer/ShopPage
@onready var main_page = $MainLayout/ContentArea/ContentVBox/PageContainer/MainPage
@onready var upgrade_page = $MainLayout/ContentArea/ContentVBox/PageContainer/UpgradePage

const LEADERBOARD_SCENE = preload(Globals.LEADERBOARD_PATH)

@onready var settings_overlay = $OverlayLayer/SettingsOverlay

@onready var game_container = %GameContainer
@onready var bottom_nav = $MainLayout/ContentArea/ContentVBox/ActionArea/BottomNav

@onready var username_label = $UsernameLabel
@onready var gold_label = $GoldLabel
@onready var high_score_label = $HighScoreLabel
@onready var expensive_label = $ExpensiveLabel

const BASE_URL = "http://127.0.0.1:8000"
@onready var profile_http_request: HTTPRequest = HTTPRequest.new()

func _ready():
	add_to_group("main_menu")
	
	$MainLayout/ContentArea/ContentVBox/ActionArea/BottomNav/ButtonsHBox/ShopBtn.pressed.connect(_show_page.bind("shop"))
	$MainLayout/ContentArea/ContentVBox/ActionArea/BottomNav/ButtonsHBox/HomeBtn.pressed.connect(_show_page.bind("main"))
	$MainLayout/ContentArea/ContentVBox/ActionArea/BottomNav/ButtonsHBox/UpgradesBtn.pressed.connect(_show_page.bind("upgrade"))
	
	$MainLayout/TopBar/SettingsBtn.pressed.connect(func(): settings_overlay.show())
	$OverlayLayer/SettingsOverlay/SettingsMenu/VBox/CloseSettingsBtn.pressed.connect(func(): settings_overlay.hide())
	$OverlayLayer/SettingsOverlay/SettingsMenu/VBox/LogoutBtn.pressed.connect(_on_logout)
	$OverlayLayer/SettingsOverlay/SettingsMenu/VBox/LeaderboardBtn.pressed.connect(_on_leaderboard_pressed)
	
	$MainLayout/ContentArea/ContentVBox/ActionArea/PlayBtn.pressed.connect(_on_play_pressed)
	expensive_label.visible = false
	
	add_child(profile_http_request)
	profile_http_request.request_completed.connect(_on_profile_loaded)
	
	_fetch_profile_data()


func _fetch_profile_data():
	if GameManager.auth_token.is_empty():
		print("Ошибка: Токен отсутствует!")
		return
		
	var headers = [
		"Authorization: Bearer " + GameManager.auth_token
	]
	profile_http_request.request(BASE_URL + "/me", headers, HTTPClient.METHOD_GET)

func _on_profile_loaded(_result, response_code, _headers, body):
	if response_code == 200:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response != null:
			GameManager.gold = response.get("gold", 100)
			GameManager.score = response.get("score", 0)
			
			GameManager.floors[0] = response.get("floor_1")
			GameManager.floors[1] = response.get("floor_2")
			GameManager.floors[2] = response.get("floor_3")
			
			_load_tower_into_ui() 
			_update_profile_ui()
			_show_page("main")
			
			# $TopBar/GoldLabel.text = str(GameManager.gold)
	else:
		print("Ошибка загрузки профиля с сервера: ", response_code)
	
func _load_tower_into_ui():
	if game_container.has_node("TowerAnchor"):
		game_container.get_node("TowerAnchor").queue_free()
		await get_tree().process_frame

	var tower_anchor = Node2D.new()
	tower_anchor.name = "TowerAnchor"
	game_container.add_child(tower_anchor)
	
	var tower_manager = TowerManager.new()
	add_child(tower_manager)
	
	tower_manager.build_tower(tower_anchor, 300, 400)

func _show_page(page_name: String):
	shop_page.hide()
	main_page.hide()
	upgrade_page.hide()
	
	expensive_label.visible = false
	
	match page_name:
		"shop": shop_page.show()
		"main": main_page.show()
		"upgrade": upgrade_page.show()

func _on_play_pressed():
	get_tree().change_scene_to_file(Globals.LEVEL_1_PATH)

func _on_leaderboard_pressed():
	$OverlayLayer/SettingsOverlay.hide()
	var leaderboard = LEADERBOARD_SCENE.instantiate()

	add_child(leaderboard)
	
func _on_close_leaderboard_pressed():
	$OverlayLayer/SettingsOverlay.show()

func _on_logout():
	GameManager.reset_session()
	get_tree().change_scene_to_file(Globals.AUTH_PATH)

func _on_buy_floor_pressed():
	var next_floor_index = -1
	for i in range(GameManager.floors.size()):
		if GameManager.floors[i] == null:
			next_floor_index = i
			break
			
	if next_floor_index == -1 or GameManager.gold < Globals.TOWER_BUY_COST:
		expensive_label.visible = true
		return
	expensive_label.visible = false
		
	GameManager.gold -= Globals.TOWER_BUY_COST
	GameManager.floors[next_floor_index] = 0 
	
	_update_profile_ui()
	GameManager.save_progress_to_server()
	await _load_tower_into_ui()

func _on_upgrade_pressed(floor_index: int, cost: int):
	if GameManager.gold < cost:
		expensive_label.visible = true
		return
	expensive_label.visible = false
		
	GameManager.gold -= cost
	GameManager.floors[floor_index] += 1
	
	_update_profile_ui()
	GameManager.save_progress_to_server()
	await _load_tower_into_ui()
	
func _update_profile_ui():
	if is_instance_valid(username_label):
		username_label.text = "Игрок: " + str(GameManager.username)
	if is_instance_valid(gold_label):
		gold_label.text = "Золото: " + str(GameManager.gold)
	if is_instance_valid(high_score_label):
		high_score_label.text = "Рекорд: " + str(GameManager.score)
