extends Camera2D

@onready var player: CharacterBody2D = $".."

func _process(delta):
	global_position = player.global_position.round()
