extends TextureButton

export (int) var slot_index = 0

func _ready():
	$SlotIndicator/SpriteKeyboard.region_rect.position.x = slot_index * 8
	$SlotIndicator/SpriteController.region_rect.position.x = slot_index * 8
	set_indicators(false)

func set_indicators(show):
	$SlotIndicator/SpriteKeyboard.visible = show
	$SlotIndicator/SpriteController.visible = show

func set_power_up(code):
	$PowerUp.set_power_up_code(code)
