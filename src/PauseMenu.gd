extends Control

const MUSIC_ON = -10
const MUSIC_OFF = -80

func _ready():
	update_music_text()

func open():
	visible = true
	get_tree().paused = true
	$CenterContainer/VBoxContainer/ResumeButton.grab_focus()
	$FliesCount.update_fly_count()

func _on_ResumeButton_pressed():
	unpause()

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_ToggleMusicButton_pressed():
	var music = not $"/root/SaveDataManager".music
	$"/root/SaveDataManager".save_options(music)
	update_music_text()

func update_music_text():
	var text = "MUSIC: ON" if $"/root/SaveDataManager".music else "MUSIC: OFF"
	$CenterContainer/VBoxContainer/ToggleMusicButton.text = text

func unpause():
	visible = false
	get_tree().paused = false
