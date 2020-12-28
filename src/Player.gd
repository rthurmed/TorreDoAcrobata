extends KinematicBody2D

const SPEED = 12000
const SPEED_ON_AIR = 10000
const GRAVITY = 200
const JUMP_POWER = -300

var movement = Vector2()
var velocity = Vector2()

var walking = false
var is_onground = false
var is_starting_jump = false
var is_holding_jump = false

func _physics_process(delta):
	is_onground = is_on_floor()
	
	process_input(delta)
	process_movement(delta)
	process_animation(delta)

func process_input(delta):
	walking = Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")
	
	if Input.is_action_pressed("ui_left"):
		movement.x = -1
	if Input.is_action_pressed("ui_right"):
		movement.x = 1
	
	if Input.is_action_just_pressed("jump"):
		is_starting_jump = true
		is_holding_jump = true
	
	if Input.is_action_just_released("jump"):
		is_holding_jump = false
	
	movement.x = lerp(movement.x, 0.0, 0.1)

func process_movement(delta):
	var speed = SPEED if is_onground else SPEED_ON_AIR
	
	# Horizontal movement
	velocity.x = movement.x * delta * speed
	
	# Vertical movement
	if is_onground and is_starting_jump:
		$JumpMaxHoldTimer.start()
		is_starting_jump = false
		velocity.y = JUMP_POWER
	
	if not is_onground:
		if is_holding_jump:
			velocity.y = lerp(velocity.y, 0, 5 * delta)
		else:
			velocity.y = GRAVITY
	
	move_and_slide(velocity, Vector2(0, -1))

func process_animation(delta):
	if is_holding_jump:
		$AnimatedSprite.play("jump")
	elif not is_onground:
		$AnimatedSprite.play("fall")
	elif walking:
		$AnimatedSprite.play("walk")
	else:
		$AnimatedSprite.play("default")
	
	$AnimatedSprite.flip_h = velocity.x < 0

func _on_JumpMaxHoldTimer_timeout():
	is_holding_jump = false
