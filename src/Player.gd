extends KinematicBody2D

const SPEED = 10000
const GRAVITY = 200

var movement = Vector2()
var velocity = Vector2()

var walking = false

func _physics_process(delta):
	process_input(delta)
	
	velocity.x = movement.x * delta * SPEED
	velocity.y = GRAVITY
	move_and_slide(velocity, Vector2(0, -1))
	
	# Update sprite
	if walking:
		$AnimatedSprite.play("walk")
	else:
		$AnimatedSprite.play("default")
	
	$AnimatedSprite.flip_h = velocity.x < 0

func process_input(delta):
	walking = Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")
	
	if Input.get_action_strength("ui_left"):
		movement.x = -1
	if Input.get_action_strength("ui_right"):
		movement.x = 1
	movement.x = lerp(movement.x, 0.0, 0.1)
