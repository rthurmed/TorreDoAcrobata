extends Control

const MUSIC_ON = -10
const MUSIC_OFF = -80

func _ready():
	$CenterContainer/VBoxContainer/PlayButton.grab_focus()

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_PlayButton_pressed():
	get_tree().change_scene("res://src/World.tscn")

func _on_ToggleMusicButton_pressed():
	if $"/root/Soundtrack".volume_db == MUSIC_ON:
		$"/root/Soundtrack".volume_db = MUSIC_OFF
	else:
		$"/root/Soundtrack".volume_db = MUSIC_ON
	update_music_text()

func update_music_text():
	if $"/root/Soundtrack".volume_db == MUSIC_ON:
		$CenterContainer/VBoxContainer/ToggleMusicButton.text = "MUSIC: ON"
	else:
		$CenterContainer/VBoxContainer/ToggleMusicButton.text = "MUSIC: OFF"
	
