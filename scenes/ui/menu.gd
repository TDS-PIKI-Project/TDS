extends Node2D

func _on_start_pressed() -> void:
	Globals.change_level(Globals.LEVEL_1_PATH)

func _on_quit_pressed() -> void:
	get_tree().quit()
