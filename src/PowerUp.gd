extends Area2D

enum PowerUpEnum {
	JUMP_PLUS_1 = 0,
	JUMP_PLUS_2 = 1,
	LIFE_PLUS_1 = 2,
	LIFE_PLUS_2 = 3,
	WALL_JUMP = 4
}

signal interacting_with_holder(power_up_holder_path)
signal stop_interacting_with_holder()

export (PowerUpEnum) var power_up_code = PowerUpEnum.JUMP_PLUS_1
export (bool) var disable_collision = false

func _ready():
	$CollisionShape2D.disabled = disable_collision
	update_sprite()

func set_power_up_code(code):
	power_up_code = code
	
	# Slots with -1 as code need to be hidden
	visible = code >= 0
	
	update_sprite()

func update_sprite():
	$Sprite.region_rect.position.x = power_up_code * 32

func _on_PowerUp_body_entered(body):
	if body.name == "Player":
		emit_signal("interacting_with_holder", get_path())

func _on_PowerUp_body_exited(body):
	if body.name == "Player":
		emit_signal("stop_interacting_with_holder")
