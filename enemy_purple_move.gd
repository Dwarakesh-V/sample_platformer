extends "res://enemy_purple.gd"

@onready var animated_sprite_2d: AnimatedSprite2D = $Area2D/AnimatedSprite2D

var initpos := position
var dir = 1
func _process(delta: float) -> void:
	if position.x >= initpos.x:
		animated_sprite_2d.flip_h = true
		dir = -1
	elif position.x <= initpos.x - 100:
		animated_sprite_2d.flip_h = false
		
	position.x += 20*delta*dir
		
