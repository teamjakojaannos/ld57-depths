extends Node2D

var _is_closed: bool = true

signal opened
signal spin_start
signal spin_speed_change(speed_scale: float)

func _open_shop() -> void:
	print("SHOP IS OPEN")
	$"../Door".open()
	opened.emit()

func _ready() -> void:
	$Open.visible = false
	$Closed.visible = true

func _on_health_hurt() -> void:
	print("CLING! TODO: sfx")
	$FidgetSpinner.play("default")
	$Closed.visible = false
	
	spin_start.emit()


func _on_health_hurt_invincible() -> void:
	print("CLING (again!) TODO: sfx")
	if $FidgetSpinner.speed_scale >= 10:
		return

	$FidgetSpinner.speed_scale += min($FidgetSpinner.speed_scale + 1, 10)
	
	if $FidgetSpinner.speed_scale == 1:
		$FidgetSpinner.play("default")
		$Open.visible = false
		$Closed.visible = false
		spin_start.emit()

	spin_speed_change.emit($FidgetSpinner.speed_scale)


func _on_fidget_spinner_animation_finished() -> void:
	$FidgetSpinner.speed_scale -= 1
	spin_speed_change.emit($FidgetSpinner.speed_scale)
	
	if $FidgetSpinner.speed_scale == 0:
		$FidgetSpinner.frame = 0
		$Open.visible = true
		if _is_closed:
			_is_closed = false
			_open_shop()
	else:
		$FidgetSpinner.play("default")
