extends Area2D

@onready var enemy_purple_1: Node2D = $"../enemy_purple_1"

var player_inside = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_inside = true
		print("player entered")

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_inside = false

func _process(delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		get_tree().reload_scene("enemyPlatform1")
