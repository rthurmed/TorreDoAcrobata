extends TextureButton

enum PowerUpEnum {
	JUMP_PLUS_1 = 0,
	JUMP_PLUS_2 = 1,
	LIFE_PLUS_1 = 2,
	LIFE_PLUS_2 = 3,
	WALL_JUMP = 4
}

export (int) var slot_index = 0

func _ready():
	$SlotIndicator/SpriteKeyboard.region_rect.position.x = slot_index * 8
	$SlotIndicator/SpriteController.region_rect.position.x = slot_index * 8
	set_indicators(false)

func set_indicators(show):
	$SlotIndicator/SpriteKeyboard.visible = show
	$SlotIndicator/SpriteController.visible = show

