extends Node2D

@onready var rcr: RayCast2D = $Area2D/rcr
@onready var rcl: RayCast2D = $Area2D/rcl
@onready var animated_sprite_2d: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var explosion: AudioStreamPlayer = $Explosion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var dir = 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if rcr.is_colliding():
		dir=-1
		animated_sprite_2d.flip_h = true
	elif rcl.is_colliding():
		dir=1
		animated_sprite_2d.flip_h = false
	position.x += dir*60*delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":

		# Player stomps enemy
		if body.velocity.y > 0 and body.position.y < position.y:
			explosion.play()
			explosion.reparent(get_tree().current_scene)
			explosion.finished.connect(explosion.queue_free)
			queue_free()
			body.velocity.y = -450 # Propogate higher

		# Enemy hits player
		else:
			body.hit()
			
