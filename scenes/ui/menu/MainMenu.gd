extends Control

@onready var shop_page = $MainLayout/ContentArea/ContentVBox/PageContainer/ShopPage
@onready var main_page = $MainLayout/ContentArea/ContentVBox/PageContainer/MainPage
@onready var upgrade_page = $MainLayout/ContentArea/ContentVBox/PageContainer/UpgradePage

const LEADERBOARD_SCENE = preload(Globals.LEADERBOARD_PATH)

@onready var settings_overlay = $SettingsOverlay

@onready var game_container = $MainLayout/ContentArea/ContentVBox/PageContainer/MainPage/GameContain
@onready var bottom_nav = $MainLayout/ContentArea/ContentVBox/ActionArea/BottomNav

func _ready():
	$MainLayout/ContentArea/ContentVBox/ActionArea/BottomNav/ButtonsHBox/ShopBtn.pressed.connect(_show_page.bind("shop"))
	$MainLayout/ContentArea/ContentVBox/ActionArea/BottomNav/ButtonsHBox/HomeBtn.pressed.connect(_show_page.bind("main"))
	$MainLayout/ContentArea/ContentVBox/ActionArea/BottomNav/ButtonsHBox/UpgradesBtn.pressed.connect(_show_page.bind("upgrade"))
	
	$MainLayout/TopBar/SettingsBtn.pressed.connect(func(): settings_overlay.show())
	$SettingsOverlay/SettingsMenu/VBox/CloseSettingsBtn.pressed.connect(func(): settings_overlay.hide())
	$SettingsOverlay/SettingsMenu/VBox/LogoutBtn.pressed.connect(_on_logout)
	$SettingsOverlay/SettingsMenu/VBox/LeaderboardBtn.pressed.connect(_on_leaderboard_pressed)
	
	$MainLayout/ContentArea/ContentVBox/ActionArea/PlayBtn.pressed.connect(_on_play_pressed)

	_show_page("main")

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

	var leaderboard = LEADERBOARD_SCENE.instantiate()

	add_child(leaderboard)

func _on_logout():
	GameManager.auth_token = ""
	GameManager.username = ""
	get_tree().change_scene_to_file(Globals.AUTH_PATH)
