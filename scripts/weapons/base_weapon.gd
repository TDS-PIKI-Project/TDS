class_name BaseWeapon extends Node2D

var weapon_data: Dictionary = {}
var projectile_data: Dictionary = {}

@export var rotation_speed: float = 5.0

@onready var sprite = $Sprite2D
@onready var cooldown_timer = $CooldownTimer

func setup(weapon_type: Globals.HandWeapons) -> void:
	weapon_data = Globals.HAND_WEAPONS[weapon_type]
	projectile_data = Globals.PROJECTILES[weapon_type]
	
	sprite.texture = load(weapon_data["texture"])
	cooldown_timer.wait_time = weapon_data["cooldown_shot"]
	cooldown_timer.one_shot = true
	cooldown_timer.autostart = false
	global_position += Vector2(-5, 3)

func _physics_process(delta: float) -> void:
	if not GameManager.is_game_active:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = get_global_mouse_position()
		global_rotation = global_position.angle_to_point(mouse_pos)
		
		var shoot_direction = Vector2.RIGHT.rotated(global_rotation)
		shoot(global_position, shoot_direction)
		return
	var target_enemy = get_closest_enemy()
	
	if target_enemy and is_instance_valid(target_enemy):
		var angle_to_enemy = global_position.angle_to_point(target_enemy.global_position)
		global_rotation = rotate_toward(global_rotation, angle_to_enemy, rotation_speed * delta)

		var shoot_direction = Vector2.RIGHT.rotated(global_rotation)
		shoot(global_position, shoot_direction)
		
func get_closest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
		
	var closest_enemy: Node2D = null
	var min_distance: float = INF
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			var dist = global_position.distance_to(enemy.global_position)
			if dist < min_distance:
				min_distance = dist
				closest_enemy = enemy
	
	return closest_enemy

func shoot(origin: Vector2, direction: Vector2) -> void:
	if not cooldown_timer.is_stopped():
		return
	
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
