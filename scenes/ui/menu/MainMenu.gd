class_name MainMenu extends Control

@onready var shop_page = $MainLayout/ContentArea/ContentVBox/PageContainer/ShopPage
@onready var main_page = $MainLayout/ContentArea/ContentVBox/PageContainer/MainPage
@onready var upgrade_page = $MainLayout/ContentArea/ContentVBox/PageContainer/UpgradePage

const LEADERBOARD_SCENE = preload(Globals.LEADERBOARD_PATH)

@onready var settings_overlay = $OverlayLayer/SettingsOverlay

@onready var game_container = %GameContainer
@onready var bottom_nav = $MainLayout/ContentArea/ContentVBox/ActionArea/BottomNav

const BASE_URL = "http://127.0.0.1:8000"
@onready var profile_http_request: HTTPRequest = HTTPRequest.new()

func _ready():
	$MainLayout/ContentArea/ContentVBox/ActionArea/BottomNav/ButtonsHBox/ShopBtn.pressed.connect(_show_page.bind("shop"))
	$MainLayout/ContentArea/ContentVBox/ActionArea/BottomNav/ButtonsHBox/HomeBtn.pressed.connect(_show_page.bind("main"))
	$MainLayout/ContentArea/ContentVBox/ActionArea/BottomNav/ButtonsHBox/UpgradesBtn.pressed.connect(_show_page.bind("upgrade"))
	
	$MainLayout/TopBar/SettingsBtn.pressed.connect(func(): settings_overlay.show())
	$OverlayLayer/SettingsOverlay/SettingsMenu/VBox/CloseSettingsBtn.pressed.connect(func(): settings_overlay.hide())
	$OverlayLayer/SettingsOverlay/SettingsMenu/VBox/LogoutBtn.pressed.connect(_on_logout)
	$OverlayLayer/SettingsOverlay/SettingsMenu/VBox/LeaderboardBtn.pressed.connect(_on_leaderboard_pressed)
	
	$MainLayout/ContentArea/ContentVBox/ActionArea/PlayBtn.pressed.connect(_on_play_pressed)
	
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
			GameManager.floors[3] = response.get("floor_4")
			GameManager.floors[4] = response.get("floor_5")
			
			_load_tower_into_ui() 
			
			_show_page("main")
			
			# $TopBar/GoldLabel.text = str(GameManager.gold)
	else:
		print("Ошибка загрузки профиля с сервера: ", response_code)
	
func _load_tower_into_ui():
	await get_tree().process_frame
	
	var tower_anchor = Node2D.new()
	tower_anchor.name = "TowerAnchor"
	game_container.add_child(tower_anchor)
	
	var tower_manager = TowerManager.new()
	add_child(tower_manager)
	
	tower_manager.build_tower(tower_anchor, 300, 350)

func _show_page(page_name: String):
	shop_page.hide()
	main_page.hide()
	upgrade_page.hide()
	
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
