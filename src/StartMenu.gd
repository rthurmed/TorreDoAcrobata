extends Control

const MUSIC_ON = -10
const MUSIC_OFF = -80

const savefile_path = "user://flies.save"

func _ready():
	$CenterContainer/VBoxContainer/PlayButton.grab_focus()
	update_fly_count()
	update_music_text()

func update_fly_count():
	$FliesCount.update_fly_count()

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_PlayButton_pressed():
	get_tree().change_scene("res://src/World.tscn")

func _on_ToggleMusicButton_pressed():
	var music = not $"/root/SaveDataManager".music
	$"/root/SaveDataManager".save_options(music)
	update_music_text()

func update_music_text():
	var text = "MUSIC: ON" if $"/root/SaveDataManager".music else "MUSIC: OFF"
	$CenterContainer/VBoxContainer/ToggleMusicButton.text = text

func _on_ResetCollectiblesButton_pressed():
	$"/root/SaveDataManager".reset_save_game()
	update_fly_count()
