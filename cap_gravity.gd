extends Area2D

@onready var base: Node2D = $".."

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		base.cap_gravity = true
