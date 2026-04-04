extends Control

@onready var outline: ColorRect = $ColorRect2
@onready var inner: ColorRect = $ColorRect2/ColorRect
@onready var label: Label = $ColorRect2/ColorRect/Label

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)


func _on_mouse_entered():
	outline.color = Color.BLACK
	inner.color = Color("e3a800")
	label.add_theme_color_override("font_color", Color("e3a800"))


func _on_mouse_exited():
	# revert colors (adjust if your default colors differ)
	outline.color = Color("e3a800")
	inner.color = Color.BLACK
	label.add_theme_color_override("font_color", Color.WHITE)


func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().change_scene_to_file("res://base.tscn")
