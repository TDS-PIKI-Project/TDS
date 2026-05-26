extends Control

@export_range(0.0, 100.0)
var health_percent: float = 100.0:
	set(value):
		health_percent = clamp(value, 0.0, 100.0)

		if is_node_ready():
			update_health_bar()

@onready var bg = $Border/Background
@onready var fill = $Border/Background/Fill


func _ready():
	update_health_bar()


func update_health_bar():
	var percent := health_percent / 100.0
	var tween = create_tween()
	tween.tween_property(
		fill,
		"size:x",
		bg.size.x * percent,
		0.2
	)


func set_health_percent(value: float):
	health_percent = value
