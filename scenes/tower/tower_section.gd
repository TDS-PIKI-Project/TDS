class_name TowerSection extends RigidBody2D

signal destroyed(section: TowerSection)
@export var health: int = 100

func _ready():
	#gravity_scale = 0.0
	add_to_group("tower_section")
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is BaseBullet:
		take_damage(body.damage)
		body.queue_free()

func get_height() -> float:
	if has_node("box") and $box.texture:
		return $box.texture.get_height() * $box.scale.y
	assert(false, "tower_section doesn't have $box? Fix it.")
	return 100.0

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		destroy()

func destroy() -> void:
	gravity_scale = 1.0
	destroyed.emit(self)
	queue_free()

func disable_enemy_wall() -> void:
	if has_node("EnemyWall/CollisionShape2D"):
		$EnemyWall/CollisionShape2D.set_deferred("disabled", true)

func enable_enemy_wall() -> void:
	if has_node("EnemyWall/CollisionShape2D"):
		$EnemyWall/CollisionShape2D.set_deferred("disabled", false)
