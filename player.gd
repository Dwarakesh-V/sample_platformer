extends CharacterBody2D

@onready var ui: CanvasLayer = %ui
@onready var timer: Timer = $Timer
@onready var hpb: Control = %hpb
@onready var hpc: Label = hpb.get_node("Label")
@onready var death: CanvasLayer = %death
@onready var control: Control = $"../death/Control"
@onready var death_bg1: ColorRect = $"../death/Control/ColorRect"
@onready var death_bg2: ColorRect = $"../death/Control/ColorRect2"
@onready var death_label: Label = $"../death/Control/Label"
@onready var low_hp_timer: Timer = $low_hp_timer
@onready var hurt: AudioStreamPlayer = $Hurt
@onready var jump: AudioStreamPlayer = $Jump

var low_hp_state := false
var normal_label_color
var normal_bar_color

const SPEED = 100.0
const JUMP_VELOCITY = -300.0

var hp = 3
var dead = false
var rolling = false
var direction = 0
var immune = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if dead:
		return

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and not rolling:
		velocity.y = JUMP_VELOCITY
		jump.play()

	# Start roll
	if Input.is_action_just_pressed("roll") and is_on_floor() and not rolling:
		rolling = true
		animated_sprite_2d.play("roll")

	# Normal movement (disabled while rolling)
	if not rolling:
		direction = Input.get_axis("move_left", "move_right")

		if direction != 0:
			velocity.x = direction * SPEED

			if animated_sprite_2d.animation != "run":
				animated_sprite_2d.play("run")

			if direction > 0:
				animated_sprite_2d.flip_h = false
			else:
				animated_sprite_2d.flip_h = true
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

			if animated_sprite_2d.animation != "idle":
				animated_sprite_2d.play("idle")

	move_and_slide()
		

func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite_2d.animation == "roll":
		var f := animated_sprite_2d.frame

		# frames 2–5 are the actual rolling movement
		if f >= 0 and f <= 4:
			if animated_sprite_2d.flip_h:
				velocity.x = -SPEED
			else:
				velocity.x = SPEED
		else:
			velocity.x = 0


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "roll":
		rolling = false
	
func hit():
	if immune or rolling or dead:
		return
	hurt.play()
	hp-=1
	
	# health bar pop
	hpb.scale = Vector2(1.25, 1.25)
	var tween = create_tween()
	tween.tween_property(hpb, "scale", Vector2(0.8,0.8), 0.4).set_trans(Tween.TRANS_BACK)
	hpc.text = "HP: " + str(hp)
	
	if hp <= 0:
		hpc.text = "Death"
		die()
			
	else:
		if hp == 1:
			normal_label_color = hpb.get_node("Label").modulate
			normal_bar_color = hpb.get_node("ColorRect").color
			low_hp_state = false

			# start the repeating timer (0.2s) that toggles colors
			if low_hp_timer.is_stopped():
				low_hp_timer.start()
		# red flash
		animated_sprite_2d.modulate = Color(1, 0.3, 0.3)

		# start immunity
		immune = true
		timer.start()

		# flicker effect while immune
		var flicker = create_tween()
		flicker.set_loops()

		flicker.tween_property(animated_sprite_2d, "modulate:a", 0.2, 0.1)
		flicker.tween_property(animated_sprite_2d, "modulate:a", 1.0, 0.1)

		timer.timeout.connect(func():
			flicker.kill()
			animated_sprite_2d.modulate = Color(1,1,1,1)
		)
		
func _on_timer_timeout() -> void:
	immune = false
	
func die():
	dead = true
	Engine.time_scale = 0.25
	animated_sprite_2d.play("die")

	await animated_sprite_2d.animation_finished
	
	death.visible = true

	death_bg1.modulate.a = 0
	death_bg2.modulate.a = 0
	death_label.modulate.a = 0

	var tween = create_tween()

	# fade backgrounds in
	tween.parallel().tween_property(death_bg1, "modulate:a", 0.8, 0.4)
	tween.parallel().tween_property(death_bg2, "modulate:a", 0.8, 0.4)

	# label appear + scale
	tween.parallel().tween_property(death_label, "modulate:a", 1.0, 0.4)
	tween.parallel().tween_property(control, "scale", Vector2(0.5,0.5),0.4)

	# pause
	tween.tween_interval(0.5)

	# fade everything out
	tween.parallel().tween_property(death_bg1, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(death_bg2, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(death_label, "modulate:a", 0.0, 0.5)
	
	await tween.finished
	
	death.visible = false
	control.scale = Vector2(0.75,0.75)
	

	position = Vector2(1, 0)
	Engine.time_scale = 1
	dead = false
	animated_sprite_2d.flip_h = false
	animated_sprite_2d.play("idle")
	hp = 3
	hpc.text = "HP: " + str(hp)
	low_hp_timer.stop()
	low_hp_state = false
	hpb.get_node("Label").modulate = normal_label_color
	hpb.get_node("ColorRect").color = normal_bar_color


func _on_low_hp_timer_timeout():
	low_hp_state = !low_hp_state

	if low_hp_state:
		hpb.get_node("Label").modulate = Color.RED
		hpb.get_node("ColorRect").color = Color.RED
	else:
		hpb.get_node("Label").modulate = normal_label_color
		hpb.get_node("ColorRect").color = normal_bar_color
