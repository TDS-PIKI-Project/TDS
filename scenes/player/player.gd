class_name Player extends CharacterBody2D

# ═══════════════════════════════════════════════════════════════════
#  ЗДОРОВЬЕ
# ═══════════════════════════════════════════════════════════════════
@export var max_health: float = 10
var cur_health: float = 10
var _is_dead: bool = false

# ═══════════════════════════════════════════════════════════════════
#  СУЩЕСТВУЮЩИЕ НОДЫ
# ═══════════════════════════════════════════════════════════════════
@onready var sprite       = $Sprite2D
@onready var weapon_pivot = $Marker2D

var current_weapon: BaseWeapon = null
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	add_to_group("player")

	var weapon_scene = preload(Globals.WEAPON_PATH)
	current_weapon = weapon_scene.instantiate()
	weapon_pivot.add_child(current_weapon)
	current_weapon.setup(Globals.HandWeapons.BIG_GUN)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	move_and_slide()

func _input(event: InputEvent) -> void:
	if _is_dead:
		return
	var speed: int = 5
	if event.is_action("shoot") and current_weapon != null:
		var mouse_pos = get_global_mouse_position()
		var direction = (mouse_pos - weapon_pivot.global_position).normalized()
		current_weapon.shoot(weapon_pivot.global_position, direction)

# ═══════════════════════════════════════════════════════════════════
#  ПОЛУЧЕНИЕ УРОНА
# ═══════════════════════════════════════════════════════════════════
func take_damage(amount: int) -> void:
	if _is_dead:
		return
	
	$HealthBar.set_health_percent(cur_health / max_health * 100)
	$HealthBar.visible = true
	cur_health -= amount
	print("[Player] получает урон: %d | HP: %d / %d" % [amount, cur_health, max_health])

	if cur_health <= 0:
		_die()

func _die() -> void:
	_is_dead = true
	set_physics_process(false)
	set_process(false)
	set_process_input(false)
	print("[Player] умер")

	#queue_free()
