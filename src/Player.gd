extends KinematicBody2D

signal dead
signal updated_power_ups(power_ups)

enum PowerUpEnum {
	JUMP_PLUS_1 = 0,
	JUMP_PLUS_2 = 1,
	LIFE_PLUS_1 = 2,
	LIFE_PLUS_2 = 3,
	WALL_JUMP = 4
}

const SPEED = 7000
const SPEED_ON_AIR = 7000
const GRAVITY = 240
const GRAVITY_MIN = 120
const GRAVITY_SLIDE_DEFAULT = 90
const GRAVITY_SLIDE_DIFF = 45 # just has 2 wall jump power ups so if you get both you dont have any slide
const JUMP_POWER = -300
const LIFE_DEFAULT = 2
const JUMP_DEFAULT_MAX_N = 1
const MAX_SLOT_N = 3

var movement = Vector2()
var velocity = Vector2()

var moving = false
var is_onground = false
var is_onceiling = false
var is_starting_jump = false
var is_holding_jump = false
var is_able_to_jump = false
var has_started_jump = false

var is_hability_walljump_enabled = false
var gravity_slide = GRAVITY_SLIDE_DEFAULT

var max_n_jumps = JUMP_DEFAULT_MAX_N
var timesjumped = 0

var max_life = LIFE_DEFAULT
var life = LIFE_DEFAULT

var is_onwall = false
var wall_direction = 0
var is_wall_sliding = false

var is_taking_damage = false
var is_imune_to_damage = false
var is_knockback_damage = false
var is_alive = true
var locked_movement = false

var is_interacting_with_holder = false
var power_up_holder = null
var selected_slot = null

var power_ups = [-1, -1, -1]

var is_godmode_enabled = false
var waiting_hurt_sound = false
var is_on_min_hold_jump_time = false
var just_released_jump = false
var applied_gravity = GRAVITY_MIN
var was_on_ground = false
var is_starting_to_fall = false

func _ready():
	update_life_ui()

func _physics_process(delta):
	if not is_alive:
		return
	
	has_started_jump = false
	
	was_on_ground = is_onground
	is_onground = is_on_floor()
	is_onceiling = is_on_ceiling()
	is_starting_to_fall = is_onground == false and was_on_ground == true
	
	is_able_to_jump = is_onground or timesjumped < max_n_jumps
	
	verify_habilities()
	
	if not is_knockback_damage:
		process_input(delta)
	
	if locked_movement:
		movement = Vector2.ZERO
		is_holding_jump = false
	
	process_actions(delta)
	process_movement(delta)
	
	if not locked_movement:
		process_animation(delta)
	
	process_audio(delta)
	
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
		is_on_min_hold_jump_time = true
		$Timer/JumpMinHoldTimer.start()
	
	if Input.is_action_just_released("jump"):
		is_holding_jump = false
		just_released_jump = true
	
	# Slots
	selected_slot = null
	
	for i in range(0, 3):
		if Input.is_action_just_pressed("slot" + str(i + 1)):
			selected_slot = i
	
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

func process_actions(_delta):
	# Exchange power up with slot
	if is_interacting_with_holder and selected_slot != null:
		var old_value = power_ups[selected_slot]
		power_ups[selected_slot] = power_up_holder.code
		power_up_holder.set_power_up_code(old_value)
		update_power_ups()

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
		is_on_min_hold_jump_time = false
	
	if is_able_to_jump and is_starting_jump:
		$Timer/JumpMaxHoldTimer.start()
		is_starting_jump = false
		timesjumped += 1
		velocity.y = JUMP_POWER
		has_started_jump = true
	
	if not is_onground:
		if is_holding_jump or is_on_min_hold_jump_time:
			velocity.y = lerp(velocity.y, 0, 5 * delta)
		elif is_wall_sliding:
			velocity.y = gravity_slide
			timesjumped = 0
		else:
			if just_released_jump or is_starting_to_fall:
				applied_gravity = GRAVITY_MIN
				just_released_jump = false
			applied_gravity = lerp(applied_gravity, GRAVITY, 5 * delta)
			velocity.y = applied_gravity
	
	# warning-ignore:return_value_discarded
	var snap = Vector2.DOWN * 8 if not is_holding_jump else Vector2.ZERO
	move_and_slide_with_snap(velocity, snap, Vector2(0, -1))
	
	if moving:
		$RayCastWall1.scale.x = movement.x
		$RayCastWall2.scale.x = movement.x

func process_animation(_delta):
	var animate = "default"
	
	if is_holding_jump or is_on_min_hold_jump_time:
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

func process_audio(_delta):
	if waiting_hurt_sound:
		$Audio/Hurt.play()
		waiting_hurt_sound = false

func hit(amount = 1):
	if is_imune_to_damage: return
	
	life -= amount
	update_life_ui()
	
	if life <= 0:
		is_alive = false
		is_imune_to_damage = true
		$AnimatedSprite.play("fall")
		$AnimationPlayer.play("die")
		$Timer/AfterDeathResetTimer.start()
		$Audio/Die.play()
	else:
		waiting_hurt_sound = true
		is_imune_to_damage = true
		$AnimationPlayer.play("hit")
		$Timer/AfterHitInvincibleTimer.start()

func process_godmode_movement(delta):
	global_position += movement * delta * 400

func verify_habilities():
	if is_hability_walljump_enabled:
		is_able_to_jump = is_able_to_jump or is_wall_sliding

func update_life_ui():
	$PlayerUI.update_life_ui(life, max_life)

func update_power_ups():
	var life_d = 0
	var n_jump = JUMP_DEFAULT_MAX_N
	var n_gravity_slide = GRAVITY_SLIDE_DEFAULT
	var enable_wall_jump = false
	
	$PlayerUI.set_power_ups(power_ups)
	
	for i in power_ups:
		if i == PowerUpEnum.LIFE_PLUS_1:
			life_d += 1
		if i == PowerUpEnum.LIFE_PLUS_2:
			life_d += 2
		if i == PowerUpEnum.JUMP_PLUS_1:
			n_jump += 1
		if i == PowerUpEnum.JUMP_PLUS_2:
			n_jump += 2
		if i == PowerUpEnum.WALL_JUMP:
			enable_wall_jump = true
			n_gravity_slide -= GRAVITY_SLIDE_DIFF
	
	max_life = LIFE_DEFAULT + life_d
	life = max_life
	max_n_jumps = n_jump
	gravity_slide = n_gravity_slide
	is_hability_walljump_enabled = enable_wall_jump
	
	$Audio/PowerUp.play()
	update_life_ui()
	emit_signal("updated_power_ups", power_ups)

func reset():
	$AnimationPlayer.stop(true)
	$AnimationPlayer.seek(0, true)
	$Timer/AfterHitInvincibleTimer.start()
	$AnimationPlayer.play("hit")
	is_imune_to_damage = true
	is_alive = true
	life = LIFE_DEFAULT
	movement = Vector2()
	power_ups = [-1, -1, -1]
	update_power_ups()

func _on_JumpMaxHoldTimer_timeout():
	is_holding_jump = false

func _on_AfterHitInvincibleTimer_timeout():
	$AnimationPlayer.stop(true)
	$AnimationPlayer.seek(0, true)
	is_imune_to_damage = false

func _on_AfterDeathResetTimer_timeout():
	# warning-ignore:return_value_discarded
	emit_signal("dead")

func _on_Any_cause_damage(pos):
	hit(1)
	
	# Apply knockback
	movement = (global_position - pos).normalized() * 2
	is_knockback_damage = true
	$Timer/KnockbackTimer.start()

func _on_KnockbackTimer_timeout():
	is_knockback_damage = false

func _on_PowerUp_interacting_with_holder(power_up_holder_path):
	power_up_holder = get_node(power_up_holder_path)
	$PlayerUI.set_key_indicators(true)
	is_interacting_with_holder = true

func _on_PowerUp_stop_interacting_with_holder():
	is_interacting_with_holder = false
	power_up_holder = null
	$PlayerUI.set_key_indicators(false)

func _on_JumpMinHoldTimer_timeout():
	is_on_min_hold_jump_time = false
