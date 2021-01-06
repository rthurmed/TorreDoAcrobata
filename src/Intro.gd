extends Control

var slide = 1

func _ready():
	change_slide(1)
	if $"/root/SaveDataManager".music:
		$Soundtrack.play()
	
func _process(_delta):
	if Input.is_action_just_released("pause"):
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://src/World.tscn")
	if Input.is_action_just_released("jump"):
		change_slide(slide + 1)
		$SceneTimer.start()

func change_slide(n):
	# Go to tower after last sldie
	if n > 6:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://src/World.tscn")
		return
	
	slide = n
	get_node("Scenes/" + str(slide)).visible = true
	if slide == 4 or slide == 6:
		$AnimationPlayer.play(str(slide))
	
	# 4th slide has the tower "diagram" so deserve more time
	$SceneTimer.wait_time = 6 if slide == 4 else 3
	$SceneTimer.start()

func _on_SceneTimer_timeout():
	change_slide(slide + 1)
