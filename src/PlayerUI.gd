extends CanvasLayer

func update_life_ui(life, max_life):
	var childs_n = $LifeContainer.get_child_count()
	for child_id in range(0, childs_n):
		var child : TextureRect = $LifeContainer.get_child(child_id)
		var id = child_id + 1
		child.visible = id <= max_life
		child.modulate = "64ffffff" if id <= max_life - life else "ffffff"

func set_key_indicators(show):
	$SlotContainer/PowerUpSlot1.set_indicators(show)
	$SlotContainer/PowerUpSlot2.set_indicators(show)
	$SlotContainer/PowerUpSlot3.set_indicators(show)
