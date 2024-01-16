extends Node

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if Input.is_action_just_pressed("reset"):
		reset_current_scene()

func reset_current_scene():
	get_tree().reload_current_scene()
