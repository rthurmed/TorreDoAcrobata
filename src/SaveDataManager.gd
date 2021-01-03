extends Node

const savefile_path = "user://flies.save"
var flies_array = []
var amount_collected = 0

const optionsfile_path = "user://options.save"
const MUSIC_ON = -10
const MUSIC_OFF = -80
var music = true

func _ready():
	load_options()
	load_game()

# ====== GAME DATA (flies) ======
func save_game(flies):
	var file = File.new()
	
	file.open(savefile_path, File.WRITE)
	file.store_var(flies)
	file.close()
	
	flies_array = flies
	update_amount_collected()

func load_game():
	var file = File.new()
	
	# Ignore if savegame dont exist
	if not file.file_exists(savefile_path):
		return
	
	file.open(savefile_path, File.READ)
	var flies: Array = file.get_var()
	file.close()
	
	flies_array = flies
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

# ====== OPTIONS ======
func save_options(music_v):
	music = music_v
	
	var file = File.new()
	
	file.open(optionsfile_path, File.WRITE)
	file.store_var({
		"music": music
	})
	file.close()
	
	update_sountrack()

func load_options():
	var file = File.new()
	
	# Ignore if savegame dont exist
	if not file.file_exists(optionsfile_path):
		return
	
	file.open(optionsfile_path, File.READ)
	var values = file.get_var()
	file.close()
	
	music = values["music"]
	update_sountrack()

func update_sountrack():
	var volume = MUSIC_ON if music else MUSIC_OFF
	$"/root/Soundtrack".volume_db = volume
