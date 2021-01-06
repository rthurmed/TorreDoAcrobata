extends Node2D

func _ready():
	if not $"/root/Soundtrack".is_playing():
		$"/root/Soundtrack".play()
	load_state()

func _physics_process(delta):
	if Input.is_action_just_released("pause"):
		$CanvasLayer/PauseMenu.open()

func save_state():
	var values = []
	for i in $Navigation2D/Flys.get_children():
		values.push_back(int(i.to_be_collected))
	$"/root/SaveDataManager".save_game(values)

func load_state():
	var values = $"/root/SaveDataManager".flies_array
	for i in range(0, values.size()):
		var fly = $Navigation2D/Flys.get_child(i)
		fly.collect(bool(values[i]))

func reset():
	# TODO: Load starting point position
	$Player.global_position = $StartingPoint.global_position
	$Player.reset()
	for i in $Navigation2D/PowerUps.get_children():
		i.reset()

func _on_Fly_collected():
	$Audio/CollectedFly.play()
	save_state()

func _on_Player_dead():
	reset()

func _on_End_body_entered(body):
	if body.name == "Player":
		$End/Chest.play("default")
		$Player.locked_movement = true
		$Player/AnimatedSprite.play("default")
		$AnimationPlayer.play("ending")

func _on_Chest_animation_finished():
	$End/CPUParticles2D.emitting = true

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "ending":
		$"/root/Soundtrack".stop()
		get_tree().change_scene("res://src/StartMenu.tscn")
