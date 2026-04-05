extends "res://enemy.gd"

func _process(delta: float) -> void:
	if rcr.is_colliding():
		dir=-1
		animated_sprite_2d.flip_h = true
	elif rcl.is_colliding():
		dir=1
		animated_sprite_2d.flip_h = false
	position.x += dir*60*delta
