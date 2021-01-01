extends Node2D

func _ready():
	if not $"/root/Soundtrack".playing:
		$"/root/Soundtrack".play()

func _physics_process(delta):
	if Input.is_action_just_released("pause"):
		$CanvasLayer/PauseMenu.open()
