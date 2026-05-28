class_name TowerSection extends RigidBody2D

signal destroyed(section: TowerSection)
var cur_health: float
var max_health: float
var section_type: Globals.SectionLevel

func _ready():
	add_to_group("tower_section")
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)
	
func set_section_type(new_type: Globals.SectionLevel = Globals.SectionLevel.ONE) -> void:
	section_type = new_type
	$box.texture = load(Globals.SECTION_INFO[section_type]["texture"])
	max_health = Globals.SECTION_INFO[section_type]["max_hp"]
	restore_health()
	
func restore_health() -> void:
	cur_health = max_health

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
	cur_health -= amount
	
	print("[tower_section] получает урон: %d | HP: %d / %d" % [amount, cur_health, max_health])
	$HealthBar.set_health_percent(cur_health / max_health * 100)
	$HealthBar.visible = true

	if cur_health <= 0:
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
