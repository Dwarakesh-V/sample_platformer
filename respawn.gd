extends Area2D

var interacted = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		interacted = true
