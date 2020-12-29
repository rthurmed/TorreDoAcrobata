extends KinematicBody2D

const SPEED = 10000
const SPEED_ON_AIR = 8000
const GRAVITY = 200
const GRAVITY_SLIDE = 50
const JUMP_POWER = -300

var movement = Vector2()
var velocity = Vector2()

var moving = false
var is_onground = false
var is_onceiling = false
var is_starting_jump = false
var is_holding_jump = false
var is_able_to_jump = false

var is_hability_walljump_enabled = true

var is_onwall = false
var wall_direction = 0
var is_wall_sliding = false

func _physics_process(delta):
	is_onground = is_on_floor()
	is_onceiling = is_on_ceiling()
	
	is_able_to_jump = is_onground
	
	if is_hability_walljump_enabled:
		is_able_to_jump = is_onground or is_wall_sliding
	
	process_input(delta)
	process_movement(delta)
	process_animation(delta)

func process_input(_delta):
	moving = Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")
	
	# movement.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	movement.x = lerp(movement.x, 0.0, 0.2)
	
	if Input.is_action_pressed("ui_left"):
		movement.x = -1
	if Input.is_action_pressed("ui_right"):
		movement.x = 1
	
	if Input.is_action_just_pressed("jump") and is_able_to_jump:
		is_starting_jump = true
		is_holding_jump = true
	
	if Input.is_action_just_released("jump"):
		is_holding_jump = false

func process_movement(delta):
	var speed = SPEED if is_onground else SPEED_ON_AIR
	
	# 2 raycasts so the player cant slide on 1 block tall walls
	is_onwall = $RayCastWall1.is_colliding() and $RayCastWall2.is_colliding()
	wall_direction = $RayCastWall1.get_collision_normal().x
	is_wall_sliding = is_hability_walljump_enabled and is_onwall and not is_onground and movement.x == wall_direction * -1
	
	# Horizontal movement
	velocity.x = movement.x * delta * speed
	
	# Vertical movement
	if is_onceiling:
		is_holding_jump = false
	
	if is_able_to_jump and is_starting_jump:
		$JumpMaxHoldTimer.start()
		is_starting_jump = false
		velocity.y = JUMP_POWER
	
	if not is_onground:
		if is_holding_jump:
			velocity.y = lerp(velocity.y, 0, 5 * delta)
		elif is_wall_sliding:
			velocity.y = GRAVITY_SLIDE
		else:
			velocity.y = GRAVITY
	
	# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2(0, -1))
	
	if moving:
		$RayCastWall1.scale.x = movement.x
		$RayCastWall2.scale.x = movement.x

func process_animation(_delta):
	var animate = "default"
	
	if is_holding_jump:
		animate = "jump"
	elif is_wall_sliding:
		animate = "slide"
	elif not is_onground:
		animate = "fall"
	elif moving:
		animate = "walk"
	
	if animate != "default":
		$AnimatedSprite.flip_h = movement.x < 0
	
	if animate == "slide":
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
	
	$AnimatedSprite.play(animate)

func _on_JumpMaxHoldTimer_timeout():
	is_holding_jump = false
