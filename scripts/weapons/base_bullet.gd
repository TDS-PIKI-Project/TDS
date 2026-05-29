class_name BaseBullet extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float
var damage: int
var spread_angle: float
var texture_path: String
var life_duration: float = 5

func _ready():
	body_entered.connect(_on_body_entered)
	if texture_path != "":
		$Sprite2D.texture = load(texture_path)
		$Sprite2D.scale = Vector2(2.5, 2.5)
		$Sprite2D.rotation = deg_to_rad(90)
	
	rotation = direction.angle()
	var spread = deg_to_rad(spread_angle)
	direction = direction.rotated(randf_range(-spread, spread))
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = life_duration
	timer.timeout.connect(free_bullet)
	timer.start()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		queue_free()
		
func free_bullet() -> void:
	queue_free()
