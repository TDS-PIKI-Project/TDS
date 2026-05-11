extends Node

# --- CONSTANTS ---
const LEVEL_1_PATH = "res://scenes/levels/level_1.tscn"
const TMP_ENEMY_PATH = "res://scenes/enemies/tmp_enemy.tscn"
const MENU_PATH = "res://scenes/ui/menu.tscn"
const PLAYER_PATH = "res://scenes/player/Player.tscn"
const BULLET_PATH = "res://scenes/weapons/Bullet.tscn"
const WEAPON_PATH = "res://scenes/weapons/Weapon.tscn"

enum HandWeapons {
	PISTOL,
	UZI,
	BIG_GUN,
}

const HAND_WEAPONS = {
	HandWeapons.PISTOL: {
		"name": "pistol",
		"texture": "res://assets/textures/hand_weapons/pistol.tres",
		"cooldown_shot": 0.2,
		"cooldown_reload": 0.6,
		"ammo_max": 8,
		"spread_angle": 1
	},
	HandWeapons.UZI: {
		"name": "uzi",
		"texture": "res://assets/textures/hand_weapons/uzi.tres",
		"cooldown_shot": 0.07,
		"cooldown_reload": 0.7,
		"ammo_max": 25,
		"spread_angle": 3
	},
	HandWeapons.BIG_GUN: {
		"name": "big gun",
		"texture": "res://assets/textures/hand_weapons/big_gun.tres",
		"cooldown_shot": 0.25,
		"cooldown_reload": 0.7,
		"ammo_max": 12,
		"spread_angle": 3
	},
}

enum Projectiles {
	PISTOL,
	UZI,
	BIG_GUN,
}

const PROJECTILES = {
	Projectiles.PISTOL: {
		"texture": "res://assets/textures/ammos/1.tres",
		"speed": 300,
		"damage": 15,
	},
	Projectiles.UZI: {
		"texture": "res://assets/textures/ammos/1.tres",
		"speed": 400,
		"damage": 10,
	},
	Projectiles.BIG_GUN: {
		"texture": "res://assets/textures/ammos/2.tres",
		"speed": 350,
		"damage": 25,
	},
}

# --- VARIABLES ---

# --- FUNCTIONS ---
func change_level(level_path: String) -> void:
	get_tree().change_scene_to_file(level_path)

func save_progress():
	pass

func load_progress():
	pass
