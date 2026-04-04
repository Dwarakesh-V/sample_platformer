extends CanvasLayer

@onready var label: Label = $Control/Label

func _process(delta: float) -> void:
	label.text = "hi"
