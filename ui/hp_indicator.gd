extends Control

var tween: Tween

@onready var hand: Control = $Shaker/Hand
@onready var shaker: ControlShaker = $Shaker

## Shake intensity when taking smallest possible amount of damage.
@export var min_shake_intensity = 5.0
## Shake intensity when dying in a single hit.
@export var max_shake_intensity = 30.0

func _ready() -> void:
	Globals.player.hurt.connect(update_indicator.bind(true))
	Globals.player.healed.connect(update_indicator.bind(false))

	update_indicator.call_deferred(false)

func update_indicator(shake: bool):
	var hp = Globals.player.get_health()
	var max_hp = Globals.player.get_max_health()

	var angle_at_empty = -130
	var angle_at_full = 130

	var percent = hp / max_hp if max_hp != 0 else 0
	var full_range = angle_at_full - angle_at_empty
	var angle = full_range * percent + angle_at_empty

	if shake:
		var old_angle = hand.rotation_degrees
		var delta = abs(angle - old_angle)
		var ratio = delta / full_range

		var shake_strength = lerp(
			min_shake_intensity,
			max_shake_intensity,
			ratio
		)
		shaker.shake(clamp(shake_strength, 0.0, max_shake_intensity))

	if tween != null:
		tween.kill()

	tween = create_tween()
	tween.tween_property(hand, "rotation_degrees", angle, 0.5)
