extends Area2D

enum PowerUpEnum {
	JUMP_PLUS_1 = 0,
	JUMP_PLUS_2 = 1,
	LIFE_PLUS_1 = 2,
	LIFE_PLUS_2 = 3,
	WALL_JUMP = 4
}

const PowerUpLabel = {
	-1: "",
	PowerUpEnum.JUMP_PLUS_1: 	"+1 pulo",
	PowerUpEnum.JUMP_PLUS_2: 	"+2 pulo",
	PowerUpEnum.LIFE_PLUS_1: 	"+1 vida",
	PowerUpEnum.LIFE_PLUS_2: 	"+2 vida",
	PowerUpEnum.WALL_JUMP:		"+wall slide"
}

signal interacting_with_holder(power_up_holder_path)
signal stop_interacting_with_holder()

export (PowerUpEnum) var power_up_code = PowerUpEnum.JUMP_PLUS_1
export (bool) var disable_collision = false
export (bool) var wavy_text = true

var code = 0

func _ready():
	$CollisionShape2D.disabled = disable_collision
	code = power_up_code
	update_sprite()
	update_text()

func reset():
	code = power_up_code
	visible = true
	update_sprite()
	update_text()

func set_power_up_code(c):
	code = c
	
	# Slots with -1 as code need to be hidden
	visible = c >= 0
	
	update_sprite()
	update_text()

func update_sprite():
	$Sprite.region_rect.position.x = code * 32

func update_text():
	$Text/RichTextLabel.bbcode_text = "[wave][center]" if wavy_text else "[center]"
	$Text/RichTextLabel.bbcode_text += PowerUpLabel[code]

func _on_PowerUp_body_entered(body):
	if body.name == "Player":
		emit_signal("interacting_with_holder", get_path())

func _on_PowerUp_body_exited(body):
	if body.name == "Player":
		emit_signal("stop_interacting_with_holder")
