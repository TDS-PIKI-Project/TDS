class_name Player extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var weapon_pivot = $Marker2D

var current_weapon: BaseWeapon = null
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
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

func _process(delta: float):
	pass
	#var mouse_pos = get_global_mouse_position()
	#var angle = global_position.angle_to_point(mouse_pos)
	#
	#if abs(angle) > PI / 2:
		#sprite.flip_h = true
		#weapon_pivot.position.x = -10
	#else:
		#sprite.flip_h = false
		#weapon_pivot.position.x = 10
	#
	##weapon_pivot.rotation = angle
	#
	#if sprite.flip_h:
		#current_weapon.sprite.flip_v = true
	#else:
		#current_weapon.sprite.flip_v = false

func _input(event: InputEvent):
	var speed: int = 5
	if event.is_action("shoot") and current_weapon != null:
		var mouse_pos = get_global_mouse_position()
		var origin = weapon_pivot.global_position
		var direction = (mouse_pos - origin).normalized()
		current_weapon.shoot(weapon_pivot.global_position, direction)
