class_name TowerBase extends RigidBody2D

var wheel_angular_speed: float

func _ready():
	GameManager.game_ended.connect(_on_game_ended)
	pass

func get_height() -> float:
	var wheel_sprite = $wheel_l
	if wheel_sprite and wheel_sprite.texture:
		return wheel_sprite.texture.get_height() * wheel_sprite.scale.y
	assert(false, "Something is very wrong... TowerBase has some error with
	getting attributes from wheels. Fix it!")
	return 100.0

func get_fastener_height() -> float:
	var fastener = $fastener
	if fastener and fastener.texture:
		return fastener.texture.get_height() * fastener.scale.y
	assert(false, "Something is very wrong... TowerBase has some error with
	getting attributes from fastener. Fix it!")
	return 100.0

func start_wheels(speed: float) -> void:
	var angular_speed = speed / 50.0
	wheel_angular_speed = angular_speed
	
func _on_game_ended() -> void:
	wheel_angular_speed = 0

func _process(delta: float) -> void:
	$wheel_l.rotation += wheel_angular_speed * delta
	$wheel_r.rotation += wheel_angular_speed * delta
