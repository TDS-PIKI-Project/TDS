class_name BaseWeapon extends Node2D

var weapon_data: Dictionary = {}
var projectile_data: Dictionary = {}

@onready var sprite = $Sprite2D
@onready var cooldown_timer = $CooldownTimer

func setup(weapon_type: Globals.HandWeapons) -> void:
	weapon_data = Globals.HAND_WEAPONS[weapon_type]
	projectile_data = Globals.PROJECTILES[weapon_type]
	
	sprite.texture = load(weapon_data["texture"])
	cooldown_timer.wait_time = weapon_data["cooldown_shot"]
	cooldown_timer.one_shot = true
	cooldown_timer.autostart = false

func shoot(origin: Vector2, direction: Vector2) -> void:
	if not cooldown_timer.is_stopped():
		return
		
	print("BANG!")
	
	cooldown_timer.start()
	
	var bullet_scene = preload(Globals.BULLET_PATH)
	var bullet = bullet_scene.instantiate()
	bullet.global_position = origin
	bullet.direction = direction
	bullet.damage = projectile_data["damage"]
	bullet.speed = projectile_data["speed"]
	bullet.spread_angle = weapon_data["spread_angle"]
	bullet.texture_path = projectile_data["texture"]
	
	get_tree().current_scene.add_child(bullet)

func _on_CooldownTimer_timeout():
	pass
