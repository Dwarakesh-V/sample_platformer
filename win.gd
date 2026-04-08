extends Area2D

@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		canvas_layer.visible = true
		
