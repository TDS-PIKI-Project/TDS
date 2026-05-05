extends Node

# --- CONSTANTS ---
const LEVEL_1_PATH = "res://scenes/enemies/tmp_enemy.tscn"
const MENU_PATH = "res://scenes/ui/menu.tscn"

# --- VARIABLES ---

# --- FUNCTIONS ---
func change_level(level_path: String) -> void:
	get_tree().change_scene_to_file(level_path)

func save_progress():
	pass

func load_progress():
	pass
