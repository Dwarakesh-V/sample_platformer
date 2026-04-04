extends Area2D

@onready var score_calc: CanvasLayer = %ui
@onready var label = score_calc.get_node("Control/Label")
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_body_entered(body: Node2D) -> void:
	audio_stream_player_2d.play()
	score_calc.coin_count += 1
	label.text = "Coins: " + str(score_calc.coin_count)
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("collected")
	await $AnimationPlayer.animation_finished
	
	queue_free()
