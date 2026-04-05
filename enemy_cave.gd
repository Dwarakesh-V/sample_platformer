extends "res://enemy.gd"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if position.x >= 1850:
		dir=-1
		animated_sprite_2d.flip_h = true
	elif position.x <= 1200:
		dir=1
		animated_sprite_2d.flip_h = false
	position.x += dir*100*delta

			
