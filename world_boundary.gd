extends Area2D

@onready var respawnpoint_1: Area2D = $"../respawnpoint1"
@onready var respawnpoint_2: Area2D = $"../respawnpoint2"
@onready var respawnpoint_3: Area2D = $"../respawnpoint3"
@onready var respawnpoint_4: Area2D = $"../respawnpoint4"
@onready var respawnpoint_5: Area2D = $"../respawnpoint5"
@onready var respawnpoint_6: Area2D = $"../respawnpoint6"
@onready var respawnpoint_7: Area2D = $"../respawnpoint7"
@onready var respawnpoint_8: Area2D = $"../respawnpoint8"
@onready var respawnpoint_9: Area2D = $"../respawnpoint9"
@onready var respawnpoint_11: Area2D = $"../respawnpoint11"

var respawn_points = []

func _ready():
	respawn_points = [
		respawnpoint_1,
		respawnpoint_2,
		respawnpoint_3,
		respawnpoint_4,
		respawnpoint_5,
		respawnpoint_6,
		respawnpoint_7,
		respawnpoint_8,
		respawnpoint_9,
		respawnpoint_11
	]

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.hit()
		if body.dead:
			return

		var latest_point = null

		for point in respawn_points:
			if point.interacted == true:
				latest_point = point

		if latest_point != null:
			body.global_position = latest_point.global_position
