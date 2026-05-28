class_name Player extends CharacterBody2D

# ═══════════════════════════════════════════════════════════════════
#  ЗДОРОВЬЕ
# ═══════════════════════════════════════════════════════════════════
@export var max_health: int = 100
var current_health: int
var _is_dead: bool = false

# ═══════════════════════════════════════════════════════════════════
#  СУЩЕСТВУЮЩИЕ НОДЫ
# ═══════════════════════════════════════════════════════════════════
@onready var sprite       = $Sprite2D
@onready var weapon_pivot = $Marker2D

var current_weapon: BaseWeapon = null

func _ready() -> void:
	add_to_group("player")
	current_health = max_health

	var weapon_scene = preload(Globals.WEAPON_PATH)
	current_weapon = weapon_scene.instantiate()
	weapon_pivot.add_child(current_weapon)
	current_weapon.setup(Globals.HandWeapons.PISTOL)

# ═══════════════════════════════════════════════════════════════════
#  ДВИЖЕНИЕ И ОРУЖИЕ (без изменений)
# ═══════════════════════════════════════════════════════════════════
func _process(delta: float) -> void:
	if _is_dead:
		return

	var mouse_pos = get_global_mouse_position()
	var angle     = global_position.angle_to_point(mouse_pos)

	if abs(angle) > PI / 2:
		sprite.flip_h          = true
		weapon_pivot.position.x = -10
	else:
		sprite.flip_h          = false
		weapon_pivot.position.x = 10

	weapon_pivot.rotation      = angle
	current_weapon.sprite.flip_v = sprite.flip_h

func _input(event: InputEvent) -> void:
	if _is_dead:
		return
	if event.is_action_pressed("shoot") and current_weapon != null:
		var mouse_pos = get_global_mouse_position()
		var direction = (mouse_pos - weapon_pivot.global_position).normalized()
		current_weapon.shoot(weapon_pivot.global_position, direction)

# ═══════════════════════════════════════════════════════════════════
#  ПОЛУЧЕНИЕ УРОНА
# ═══════════════════════════════════════════════════════════════════
func take_damage(amount: int) -> void:
	if _is_dead:
		return

	current_health -= amount
	print("[Player] получает урон: %d | HP: %d / %d" % [amount, current_health, max_health])

	if current_health <= 0:
		_die()

func _die() -> void:
	_is_dead = true
	set_physics_process(false)
	set_process(false)
	set_process_input(false)
	print("[Player] умер")

	queue_free()

	
