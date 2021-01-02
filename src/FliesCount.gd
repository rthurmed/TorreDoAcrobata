extends Control

func update_fly_count():
	$TextureRect/Label.text = str($"/root/SaveDataManager".amount_collected)
