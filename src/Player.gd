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
var is_hability_doublejump_enabled = true

var max_n_jumps = 1
var timesjumped = 0

var max_life = 2
var life = 2

var is_onwall = false
var wall_direction = 0
var is_wall_sliding = false

var is_taking_damage = false
var is_imune_to_damage = false
var is_knockback_damage = false
var is_alive = true

var is_godmode_enabled = false

func _ready():
	update_life_ui()

func _physics_process(delta):
	if not is_alive:
		return
	
	is_onground = is_on_floor()
	is_onceiling = is_on_ceiling()
	
	is_able_to_jump = is_onground or timesjumped < max_n_jumps
	
	verify_habilities()
	
	if not is_knockback_damage:
		process_input(delta)
	
	process_movement(delta)
	process_animation(delta)
	
	if is_onground:
		is_knockback_damage = false

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
	
	# DEBUG
	if Input.is_action_just_pressed("godmode"):
		is_godmode_enabled = not is_godmode_enabled
		$CollisionShape2D.disabled = is_godmode_enabled
		$AnimatedSprite.modulate = "80ffffff" if is_godmode_enabled else "ffffff"
	
	if is_godmode_enabled:
		movement.y = 0
		if Input.is_action_pressed("ui_up"):
			movement.y = -1
		if Input.is_action_pressed("ui_down"):
			movement.y = 1

func process_movement(delta):
	var speed = SPEED if is_onground else SPEED_ON_AIR
	
	if is_godmode_enabled:
		process_godmode_movement(delta)
		return
	
	# 2 raycasts so the player cant slide on 1 block tall walls
	is_onwall = $RayCastWall1.is_colliding() and $RayCastWall2.is_colliding()
	wall_direction = $RayCastWall1.get_collision_normal().x
	is_wall_sliding = is_hability_walljump_enabled and is_onwall and not is_onground and movement.x == wall_direction * -1
	
	# Horizontal movement
	velocity.x = movement.x * delta * speed
	
	# Vertical movement
	if is_onground:
		timesjumped = 0
	
	if is_onceiling:
		is_holding_jump = false
	
	if is_able_to_jump and is_starting_jump:
		$JumpMaxHoldTimer.start()
		is_starting_jump = false
		timesjumped += 1
		velocity.y = JUMP_POWER
	
	if not is_onground:
		if is_holding_jump:
			velocity.y = lerp(velocity.y, 0, 5 * delta)
		elif is_wall_sliding:
			velocity.y = GRAVITY_SLIDE
			timesjumped = 0
		else:
			velocity.y = GRAVITY
	
	# warning-ignore:return_value_discarded
	var snap = Vector2.DOWN * 16 if not is_holding_jump else Vector2.ZERO
	move_and_slide_with_snap(velocity, snap, Vector2(0, -1))
	
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

func hit(amount = 1):
	if is_imune_to_damage: return
	
	life -= amount
	update_life_ui()
	
	if life <= 0:
		is_alive = false
		is_imune_to_damage = true
		$AnimatedSprite.play("fall")
		$AnimationPlayer.play("die")
		$AfterDeathResetTimer.start()
	else:
		is_imune_to_damage = true
		$AnimationPlayer.play("hit")
		$AfterHitInvincibleTimer.start()

func process_godmode_movement(delta):
	global_position += movement * delta * 400

func verify_habilities():
	if is_hability_walljump_enabled:
		is_able_to_jump = is_able_to_jump or is_wall_sliding
	
	if is_hability_doublejump_enabled:
		# This can be dynamically changed to enable triple and quatruple jump
		max_n_jumps = 2

func update_life_ui():
	$PlayerUI.update_life_ui(life, max_life)

func _on_JumpMaxHoldTimer_timeout():
	is_holding_jump = false

func _on_AfterHitInvincibleTimer_timeout():
	$AnimationPlayer.stop(true)
	is_imune_to_damage = false

func _on_AfterDeathResetTimer_timeout():
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

func _on_Any_cause_damage(pos):
	hit(1)
	
	# Apply knockback
	movement = (global_position - pos).normalized() * 2
	is_knockback_damage = true
	$KnockbackTimer.start()

func _on_KnockbackTimer_timeout():
	is_knockback_damage = false

func _on_PowerUp_interacting_with_holder(power_up_holder_path):
	$PlayerUI.set_key_indicators(true)

func _on_PowerUp_stop_interacting_with_holder():
	$PlayerUI.set_key_indicators(false)
