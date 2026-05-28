extends CharacterBody2D
class_name BaseEnemy

@export var speed: float               = 150.0
@export var push_force: float          = 10.0
@export var lane_attraction: float     = 2.0
@export var collision_radius_multiplier: float = 0.9
@export var push_x_strength: float    = 1.5
@export var push_y_strength: float    = 1.0
@export var velocity_lerp_speed: float = 0.1

var mass: float            = 1.0
var max_health: int        = 100
var current_health: int    = 100
var attack_damage: int     = 10
var attack_cooldown: float = 1.5

var lane_clamp_offset: float = 0.0
var target_lane_y: float     = 0.0
var all_lanes: Array         = []
var neighbours: Array        = []
var _attack_targets: Array   = []

var _attack_timer: float     = 0.0
var _is_attacking: bool      = false
var _is_dead: bool           = false

var _collision_shape: CollisionShape2D = null
var _detector_area: Area2D             = null
var _attack_area: Area2D               = null
var _anim_player: AnimationPlayer      = null
var _skin_suffix: int = 1

var enemy_type: Globals.EnemyType = Globals.EnemyType.SMALL

func _ready() -> void:
	add_to_group("enemies")
	_init_stats()
	current_health = max_health

	if has_node("CollisionShape2D"):
		_collision_shape = $CollisionShape2D
	if has_node("AnimationPlayer"):
		_anim_player = $AnimationPlayer

	if has_node("DetectorArea"):
		_detector_area = $DetectorArea
		_detector_area.body_entered.connect(_on_detector_body_entered)
		_detector_area.body_exited.connect(_on_detector_body_exited)

	if has_node("AttackArea"):
		_attack_area = $AttackArea
		_attack_area.body_entered.connect(_on_attack_area_body_entered)
		_attack_area.body_exited.connect(_on_attack_area_body_exited)

	_play_anim("walk")

func _init_stats() -> void:
	var data: Dictionary = Globals.ENEMIES[enemy_type]
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	mass                = data["mass"]
	push_force          = data["push_force"]
	push_x_strength     = data["push_x_strength"]
	push_y_strength     = data["push_y_strength"]
	lane_attraction     = data["lane_attraction"]
	velocity_lerp_speed = data["velocity_lerp_speed"]
	lane_clamp_offset   = data["lane_clamp_offset"]

	speed           = rng.randf_range(data["speed_min"],   data["speed_max"])
	max_health      = rng.randi_range(data["health_min"],  data["health_max"])
	attack_damage   = rng.randi_range(data["damage_min"],  data["damage_max"])
	attack_cooldown = rng.randf_range(data["cooldown_min"], data["cooldown_max"])
	_skin_suffix = randi_range(1, 3)

	var s: float = rng.randf_range(data["scale_min"], data["scale_max"])
	scale = Vector2(s, s)

func get_physic_colision_size() -> float:
	if _collision_shape == null or _collision_shape.shape == null:
		return 0.0
	if _collision_shape.shape is RectangleShape2D:
		var rect: Rect2 = _collision_shape.shape.get_rect()
		return max(rect.size.x, rect.size.y)
	elif _collision_shape.shape is CircleShape2D:
		return _collision_shape.shape.radius * 2.0
	push_error("BaseEnemy: неизвестная форма коллизии")
	return 0.0

func _physics_process(_delta: float) -> void:
	if _is_dead or _is_attacking:
		return

	var push_vector: Vector2 = Vector2.ZERO
	var my_size: float = get_physic_colision_size()

	for other in neighbours:
		if other == self or not is_instance_valid(other):
			continue
		if not (other is BaseEnemy):
			continue

		var other_enemy: BaseEnemy = other as BaseEnemy
		var other_size: float  = other_enemy.get_physic_colision_size()
		var other_mass: float  = other_enemy.mass
		var radius: float      = (my_size + other_size) * 0.5 * collision_radius_multiplier
		var dist: float        = global_position.distance_to(other_enemy.global_position)

		if dist < radius and dist > 0.001:
			var diff: Vector2 = global_position - other_enemy.global_position

			var x_overlap: float = 1.0 - clamp(abs(diff.x) / radius, 0.0, 1.0)

			var climb_factor: float = other_mass / (mass + other_mass)

			push_vector.x += diff.normalized().x * (radius - dist) * push_x_strength * 0.3

			push_vector.y += diff.normalized().y * (radius - dist) * push_y_strength * x_overlap * climb_factor

	var target_velocity: Vector2 = Vector2(-speed, 0.0) + push_vector * push_force
	
	target_velocity.y += (target_lane_y - global_position.y) * lane_attraction

	velocity = velocity.lerp(target_velocity, velocity_lerp_speed)
	move_and_slide()

	global_position.y = clamp(
		global_position.y,
		target_lane_y - lane_clamp_offset,
		target_lane_y + lane_clamp_offset
	)

func _process(delta: float) -> void:
	if _is_dead:
		return
	if _attack_timer > 0.0:
		_attack_timer -= delta
		return
	if not _attack_targets.is_empty() and not _is_attacking:
		_attack_targets = _attack_targets.filter(
			func(t: Node) -> bool: return is_instance_valid(t)
		)
		if not _attack_targets.is_empty():
			_perform_attack(_attack_targets[0])

func _perform_attack(target: Node) -> void:
	_is_attacking = true
	velocity      = Vector2.ZERO
	_play_anim("attack")

	if _anim_player != null and _anim_player.has_animation("attack"):
		await _anim_player.animation_finished

	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(attack_damage)
		print("[%s] наносит урон: %d → цели '%s'" % [name, attack_damage, target.name])

	_attack_timer = attack_cooldown
	_is_attacking = false
	_play_anim("walk")

func take_damage(amount: int) -> void:
	if _is_dead:
		return
	current_health -= amount
	print("[%s] получает урон: %d | HP: %d / %d" % [name, amount, current_health, max_health])
	_play_anim("hurt")
	if current_health <= 0:
		_die()

func _die() -> void:
	_is_dead = true
	_is_attacking = false
	set_physics_process(false)
	set_process(false)
	print("[%s] умирает" % name)
	
	_play_anim("death")
	
	if _anim_player != null:
		var death_anim = "death_" + str(_skin_suffix)
		if _anim_player.has_animation(death_anim):
			await _anim_player.animation_finished
		elif _anim_player.has_animation("death"):
			await _anim_player.animation_finished
	
	queue_free()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("towers") or body.is_in_group("player"):
		if body not in _attack_targets:
			_attack_targets.append(body)

func _on_attack_area_body_exited(body: Node2D) -> void:
	_attack_targets.erase(body)

func _on_detector_body_entered(body: Node2D) -> void:
	if body != self and body.is_in_group("enemies"):
		if body not in neighbours:
			neighbours.append(body)

func _on_detector_body_exited(body: Node2D) -> void:
	neighbours.erase(body)

func _play_anim(anim_name: String) -> void:
	if _anim_player == null:
		return
	if _is_dead and anim_name != "death":
		return
	if _is_attacking and anim_name in ["walk", "hurt"]:
		return
	
	var skinned_name = anim_name + "_" + str(_skin_suffix)
	if _anim_player.has_animation(skinned_name):
		if _anim_player.current_animation != skinned_name:
			_anim_player.play(skinned_name)
	elif _anim_player.has_animation(anim_name):
		if _anim_player.current_animation != anim_name:
			_anim_player.play(anim_name)
