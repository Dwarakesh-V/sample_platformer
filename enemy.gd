extends Node2D

@onready var rcr: RayCast2D = $Area2D/rcr
@onready var rcl: RayCast2D = $Area2D/rcl
@onready var animated_sprite_2d: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var explosion: AudioStreamPlayer = $Explosion
@onready var base: Node2D = $".."

var dir = 1
var speed = 35
var max_distance = 40
var start_x

func _ready() -> void:
	start_x = position.x
	
	# start direction from scale
	dir = sign(scale.x)
	if dir == 0:
		dir = 1
	
	scale.x = dir

func _process(delta: float) -> void:
	position.x += dir * speed * delta

	if position.x > start_x + max_distance:
		dir = -1
		scale.x = -1
		
	elif position.x < start_x - max_distance:
		dir = 1
		scale.x = 1


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":

		# Player stomps enemy
		if (body.velocity.y > 0 or body.position.y < position.y) or ((body.velocity.y < 0 or body.position.y > position.y) and base.inv_gravity):
			explosion.play()
			explosion.reparent(get_tree().current_scene)
			explosion.finished.connect(explosion.queue_free)
			queue_free()
			
			if not base.inv_gravity:
				body.velocity.y = -450
			else:
				body.velocity.y = 450
			body.jump_count = 0
			body.get_node("AnimatedSprite2D").play("idle")
			body.dash_ready = true
			body.air_dash_available = true

		else:
			body.hit()
