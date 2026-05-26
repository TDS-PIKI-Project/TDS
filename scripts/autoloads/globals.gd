extends Node

# --- CONSTANTS ---
const LEVEL_1_PATH = "res://scenes/levels/level_1.tscn"
const MENU_PATH = "res://scenes/ui/menu.tscn"
const PLAYER_PATH = "res://scenes/player/Player.tscn"
const BULLET_PATH = "res://scenes/weapons/Bullet.tscn"
const WEAPON_PATH = "res://scenes/weapons/Weapon.tscn"
const ENEMY_PATH = "res://scenes/enemies/tmp_enemy.tscn"
const TOWER_BASE_PATH = "res://scenes/tower/TowerBase.tscn"
const TOWER_SECTION_PATH = "res://scenes/tower/TowerSection.tscn"
const SCORE_PATH = "res://scenes/levels/score.tscn"
const AUTH_PATH = "res://scenes/ui/authorization/Auth.tscn"
const MAIN_MENU_PATH = "res://scenes/ui/menu/MainMenu.tscn"
const LEADERBOARD_PATH = "res://scenes/ui/board/LeaderboardScene.tscn"

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

enum EnemyType {
	SMALL,
	MEDIUM,
	LARGE,
}

const ENEMIES = {
	EnemyType.SMALL: {
		"mass":                 1.0,
		"push_force":           9.0,
		"push_x_strength":      1.2,
		"push_y_strength":      4.0,
		"lane_attraction":      3.5,
		"velocity_lerp_speed":  0.18,
		"lane_clamp_offset":    55.0,
		"speed_min":            185.0,
		"speed_max":            230.0,
		"health_min":           30,
		"health_max":           50,
		"damage_min":           5,
		"damage_max":           11,
		"cooldown_min":         0.9,
		"cooldown_max":         1.4,
		"scale_min":            0.80,
		"scale_max":            0.95,
		"score":                1,
	},
	EnemyType.MEDIUM: {
		"mass":                 2.5,
		"push_force":           11.0,
		"push_x_strength":      1.5,
		"push_y_strength":      2.5,
		"lane_attraction":      2.5,
		"velocity_lerp_speed":  0.10,
		"lane_clamp_offset":    40.0,
		"speed_min":            125.0,
		"speed_max":            160.0,
		"health_min":           90,
		"health_max":           130,
		"damage_min":           17,
		"damage_max":           27,
		"cooldown_min":         1.5,
		"cooldown_max":         2.1,
		"scale_min":            0.92,
		"scale_max":            1.10,
		"score":                3,
	},
	EnemyType.LARGE: {
		"mass":                 5.0,
		"push_force":           14.0,
		"push_x_strength":      1.4,
		"push_y_strength":      1.0,
		"lane_attraction":      5.0,
		"velocity_lerp_speed":  0.06,
		"lane_clamp_offset":    25.0,
		"speed_min":            70.0,
		"speed_max":            100.0,
		"health_min":           220,
		"health_max":           320,
		"damage_min":           45,
		"damage_max":           70,
		"cooldown_min":         2.5,
		"cooldown_max":         3.5,
		"scale_min":            1.28,
		"scale_max":            1.55,
		"score":                5,
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
