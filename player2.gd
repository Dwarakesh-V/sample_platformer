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

@onready var dash_timer: Timer = $DashTimer
@onready var trail_timer: Timer = $TrailTimer

var low_hp_state := false
var normal_label_color
var normal_bar_color

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2

const DASH_SPEED = 350
const DASH_TIME = 0.15

var jump_count = 0
var dashing = false

var hp = 3
var dead = false
var direction = 0
var immune = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	if dead:
		return

	# gravity
	if not is_on_floor() and not dashing:
		velocity += get_gravity() * delta
	else:
		jump_count = 0

	# jump / double jump
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS and not dashing:
		jump_count += 1
		velocity.y = JUMP_VELOCITY
		jump.play()

		if jump_count == 2:
			animated_sprite_2d.play("roll")

	# dash
	if Input.is_action_just_pressed("dash") and not dashing:
		start_dash()

	# movement
	if not dashing:
		direction = Input.get_axis("move_left", "move_right")

		if direction != 0:
			velocity.x = direction * SPEED

			if is_on_floor():
				if animated_sprite_2d.animation != "run":
					animated_sprite_2d.play("run")

			animated_sprite_2d.flip_h = direction < 0

		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

			if is_on_floor():
				if animated_sprite_2d.animation != "idle":
					animated_sprite_2d.play("idle")

	move_and_slide()


func start_dash():

	dashing = true
	immune = true

	var dash_dir = Input.get_vector("move_left", "move_right", "jump", "ui_down")

	# if no input, dash toward facing direction
	if dash_dir == Vector2.ZERO:
		dash_dir = Vector2.LEFT if animated_sprite_2d.flip_h else Vector2.RIGHT

	dash_dir = dash_dir.normalized()

	velocity = dash_dir * DASH_SPEED

	dash_timer.start()
	trail_timer.start()

func _on_dash_timer_timeout():
	dashing = false
	immune = false
	trail_timer.stop()

func _on_trail_timer_timeout():
	var ghost = animated_sprite_2d.duplicate()
	ghost.modulate = Color(0.4, 0.7, 1, 0.6)
	ghost.global_position = animated_sprite_2d.global_position
	ghost.flip_h = animated_sprite_2d.flip_h

	get_parent().add_child(ghost)

	var tween = create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.25)
	tween.tween_callback(ghost.queue_free)


func hit():
	if immune or dead:
		return

	hurt.play()
	hp -= 1

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

			if low_hp_timer.is_stopped():
				low_hp_timer.start()

		animated_sprite_2d.modulate = Color(1, 0.3, 0.3)

		immune = true
		timer.start()

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

	tween.parallel().tween_property(death_bg1, "modulate:a", 0.8, 0.4)
	tween.parallel().tween_property(death_bg2, "modulate:a", 0.8, 0.4)

	tween.parallel().tween_property(death_label, "modulate:a", 1.0, 0.4)
	tween.parallel().tween_property(control, "scale", Vector2(0.5,0.5),0.4)

	tween.tween_interval(0.5)

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
