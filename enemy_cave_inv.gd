extends "res://enemy_cave.gd"

func _ready() -> void:
	dir = -1
	animated_sprite_2d.flip_h = true
