extends Node

const savefile_path = "user://flies.save"
var flies_array = []
var amount_collected = 0

func _ready():
	load_game()

func save_game(values):
	var file = File.new()
	
	file.open(savefile_path, File.WRITE)
	file.store_var(values)
	file.close()
	
	flies_array = values
	update_amount_collected()

func load_game():
	var file = File.new()
	
	# Ignore if savegame dont exist
	if not file.file_exists(savefile_path):
		return
	
	file.open(savefile_path, File.READ)
	var values: Array = file.get_var()
	file.close()
	
	flies_array = values
	update_amount_collected()

func reset_save_game():
	var dir = Directory.new()
	dir.remove(savefile_path)
	for i in range(0, flies_array.size()):
		flies_array[i] = true
	update_amount_collected()

func update_amount_collected():
	amount_collected = 0
	
	# Count amount of collected flies
	for value in flies_array:
		if not value:
			amount_collected += 1
