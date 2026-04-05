extends Node2D

@onready var explosion: AudioStreamPlayer = $Explosion

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":

		# Player stomps enemy
		if body.velocity.y > 0:
			explosion.play()
			explosion.reparent(get_tree().current_scene)
			explosion.finished.connect(explosion.queue_free)
			queue_free()

			body.velocity.y = -675
			body.jump_count = 0
			body.get_node("AnimatedSprite2D").play("idle")
			body.dash_ready = true
			body.air_dash_available = true

		else:
			body.hit()
			
