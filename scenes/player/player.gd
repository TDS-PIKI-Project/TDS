class_name Player extends CharacterBody2D

@export var max_health: float = 100
var cur_health: float = 100
var _is_dead: bool = false

@onready var sprite       = $Sprite2D
@onready var weapon_pivot = $Marker2D

var current_weapon: BaseWeapon = null
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_ended.connect(_on_game_ended)
	
	add_to_group("player")
	

	var weapon_scene = preload(Globals.WEAPON_PATH)
	current_weapon = weapon_scene.instantiate()
	weapon_pivot.add_child(current_weapon)
	current_weapon.setup(Globals.HandWeapons.BIG_GUN)

func _physics_process(delta: float) -> void:
	if not GameManager.is_game_active:
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	move_and_slide()

func _input(event: InputEvent) -> void:
	if _is_dead or not GameManager.is_game_active:
		return
	var speed: int = 5
	if event.is_action("shoot") and current_weapon != null:
		var mouse_pos = get_global_mouse_position()
		var direction = (mouse_pos - weapon_pivot.global_position).normalized()
		current_weapon.shoot(weapon_pivot.global_position, direction)

func take_damage(amount: int) -> void:
	if _is_dead or not GameManager.is_game_active:
		return
	
	cur_health -= amount
	$HealthBar.set_health_percent(cur_health / max_health * 100)
	$HealthBar.visible = true
	print("[Player] получает урон: %d | HP: %d / %d" % [amount, cur_health, max_health])

	if cur_health <= 0:
		GameManager.game_ended.emit()
		
func _on_game_started() -> void:
	_is_dead = false
	set_physics_process(true)
	set_process(true)
	set_process_input(true)
	cur_health = max_health
	GameManager.is_game_active = true
	
func _on_game_ended() -> void:
	GameManager.is_game_active = false
	$HealthBar.visible = false
	_die()

func _die() -> void:
	_is_dead = true
	set_physics_process(false)
	set_process(false)
	set_process_input(false)
	print("[Player] умер")
	

	#queue_free()
