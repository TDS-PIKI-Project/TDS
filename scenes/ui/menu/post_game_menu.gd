extends ColorRect

@onready var score_label: Label = $PanelContainer/MarginContainer/MainVBox/StatsVBox/ScoreLabel
@onready var gold_label: Label = $PanelContainer/MarginContainer/MainVBox/StatsVBox/GoldLabel
@onready var enemies_label: Label = $PanelContainer/MarginContainer/MainVBox/StatsVBox/EnemiesLabel
@onready var time_label: Label = $PanelContainer/MarginContainer/MainVBox/StatsVBox/TimeLabel

@onready var retry_btn: Button = $PanelContainer/MarginContainer/MainVBox/ButtonsHBox/RetryBtn
@onready var menu_btn: Button = $PanelContainer/MarginContainer/MainVBox/ButtonsHBox/MenuBtn

@onready var new_record_label: Label = $NewRecord

func _ready() -> void:
	hide()
	new_record_label.hide()
	retry_btn.pressed.connect(_on_retry_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)

func show_game_over(final_score: int, killed_enemies: int, earned_gold: int, \
					 survived_time_sec: float) -> void:
	new_record_label.hide()
	score_label.text = "        Очки: " + str(final_score)
	gold_label.text = "        Собрано золота: " + str(earned_gold)
	enemies_label.text = "        Убито врагов: " + str(killed_enemies)
	var minutes = int(survived_time_sec) / 60
	var seconds = int(survived_time_sec) % 60
	time_label.text = "        Время выживания: %02d:%02d" % [minutes, seconds]
	
	show()

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file(Globals.LEVEL_1_PATH)

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(Globals.MAIN_MENU_PATH)
	
func activate_new_record_animation() -> void:
	new_record_label.show()
	
	new_record_label.rotation = 0
	new_record_label.scale = Vector2.ONE
	
	var tween = create_tween().set_loops() 
	
	tween.tween_property(new_record_label, "rotation", 0.08, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(new_record_label, "scale", Vector2(1.2, 1.2), 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.chain().tween_property(new_record_label, "rotation", 0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(new_record_label, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.chain().tween_property(new_record_label, "rotation", -0.08, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(new_record_label, "scale", Vector2(1.2, 1.2), 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.chain().tween_property(new_record_label, "rotation", 0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(new_record_label, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
