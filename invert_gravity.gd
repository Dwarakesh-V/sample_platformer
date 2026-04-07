extends Area2D

@onready var base: Node2D = $".."

func _on_body_entered(body: Node2D) -> void:
	body.up_direction = Vector2(0, 1)
	body.get_node("AnimatedSprite2D").play("roll")

	var tween = create_tween()
	tween.tween_property(body, "rotation_degrees", 180, 0.3)\
		.set_ease(Tween.EASE_IN_OUT)
		
	
	base.inv_gravity = true
	base.cap_gravity = false
