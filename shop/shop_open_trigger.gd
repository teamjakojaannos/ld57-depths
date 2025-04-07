extends Node2D

var _is_closed: bool = true

signal opened
signal spin_start
signal spin_speed_change(speed_scale: float)

var _lock_spinning: bool = true

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
	$Open.visible = false
	$Tuplausmusa.play()

	spin_start.emit()


func _on_health_hurt_invincible() -> void:
	print("CLING (again!) TODO: sfx")
	$HitSfx.play()
	
	if $FidgetSpinner.speed_scale >= 10:
		return

	$FidgetSpinner.speed_scale += min($FidgetSpinner.speed_scale + 1, 10)
	$Tuplausmusa.pitch_scale = 1.0 + (($FidgetSpinner.speed_scale - 1) / 25.0)
	
	if $FidgetSpinner.speed_scale == 1:
		$FidgetSpinner.play("default")
		$Tuplausmusa.play()
		$Open.visible = false
		$Closed.visible = false
		spin_start.emit()

	spin_speed_change.emit($FidgetSpinner.speed_scale)


func _on_fidget_spinner_animation_finished() -> void:
	$FidgetSpinner.speed_scale -= 1
	$Tuplausmusa.pitch_scale = 1.0 + (($FidgetSpinner.speed_scale + 1) / 15.0)
	spin_speed_change.emit($FidgetSpinner.speed_scale)
	
	if $FidgetSpinner.speed_scale == 0:
		_lock_spinning = true
		$FidgetSpinner.frame = 0
		$Open.visible = true
		if _is_closed:
			_is_closed = false
			_open_shop()
	else:
		$FidgetSpinner.play("default")


func _on_tuplausmusa_finished() -> void:
	if $Open.visible:
		$TuplausmusaEnd.play(2.18)
	else:
		$Tuplausmusa.play(1.333)
