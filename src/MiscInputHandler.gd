extends Node

func _process(_delta):
	if Input.is_action_just_released("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
