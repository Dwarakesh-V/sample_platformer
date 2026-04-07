extends Area2D

@onready var enemyplatform: Node2D = $"../enemyplatform"
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

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
		audio_stream_player_2d.play()
		enemyplatform.queue_free()
		#enemyplatform = preload("res://enem_plat.tscn").instantiate()
		get_parent().add_child(enemyplatform)
