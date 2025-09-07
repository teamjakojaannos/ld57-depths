@tool
extends CanvasLayer
class_name BossHealthbar

@export var health_percentage: float = 0.9:
	get:
		return health_percentage
	set(value):
		health_percentage = value
		var progressbar = get_node_or_null("Control/Progress")
		if progressbar is Control:
			progressbar.scale.x = health_percentage

@export var boss: Health

func _ready() -> void:
	if boss == null:
		return

	if not boss.hurt.is_connected(_update):
		boss.hurt.connect(_update)

	_update()

func _update() -> void:
	health_percentage = boss.current_health / boss.max_health
