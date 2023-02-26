extends KinematicBody2D

var SPEED := 600
var JUMP_POWER := SPEED * 1.5
var GRAVITY := 1200
var VELOCITY := Vector2(0, 0)
var UP_NORMAL := Vector2(0, -1)
var AIR_STRAFE_RESISTANCE := 50
var AIR_STRAFE_ACCELERATION := 50
var AIR_MOMENTUM_NORMAL := 0
var FLOOR_SNAP := -UP_NORMAL * 2
var JUMP_FORGIVENESS := 0.15 # number of seconds of leeway to jump after falling
var JUMP_TIMER: Timer
var MAX_AIR_JUMP_COUNT := 1
var WORLD_LIMIT = 3000

onready var hurt_sfx = $HurtSoundEffect
onready var jump_sfx = $JumpSoundEffect
onready var coin_sfx = $CollectCoinSoundEffect
onready var was_on_floor := is_on_floor()

var was_falling := false
var air_jump_count := 0

signal animate
signal falling

func _ready():
	JUMP_TIMER = Timer.new()
	JUMP_TIMER.one_shot = true
	add_child(JUMP_TIMER)

func _physics_process(delta: float):
	check_world_limit()
	var snap = FLOOR_SNAP
	set_air_momentum_normal()
	apply_gravity(delta)
	apply_strafe()
	if Input.is_action_just_pressed("up") and can_jump():
		snap = Vector2.ZERO
		jump()
	# warning-ignore:return_value_discarded
	move_and_slide_with_snap(VELOCITY, snap, UP_NORMAL)
	emit_signal("animate", PlayerMotion.new(VELOCITY, is_on_floor()))
	
	if is_on_floor() and not was_on_floor:
		was_on_floor = true
		air_jump_count = 0
	elif not is_on_floor() and was_on_floor:
		was_on_floor = false
		JUMP_TIMER.start(JUMP_FORGIVENESS)
		
	if is_falling() and not was_falling:
		was_falling = true
		emit_signal("falling", true)
	elif not is_falling() and was_falling:
		was_falling = false
		emit_signal("falling", false)

func apply_gravity(delta: float):
	if is_on_ceiling() and VELOCITY.y < 0:
		VELOCITY.y = 0
	
	if can_fall():
		VELOCITY.y += GRAVITY*delta
	elif VELOCITY.y > 0:
		VELOCITY.y = 0

func should_move_left():
	return Input.is_action_pressed("left") and not Input.is_action_pressed("right")

func should_move_right():
	return Input.is_action_pressed("right") and not Input.is_action_pressed("left")

func can_fall():
	return not is_on_floor()

func is_falling():
	return VELOCITY.y > 0 and not is_on_floor()

func can_jump() -> bool:
	return (is_on_floor() or JUMP_TIMER.time_left > 0 or air_jump_count < MAX_AIR_JUMP_COUNT)

func jump(with_sound: bool = true):
	if is_on_floor() or JUMP_TIMER.time_left > 0:
		# ground jump
		pass
	else:
		air_jump_count += 1
	if with_sound:
		jump_sfx.play()
	VELOCITY.y = -JUMP_POWER

func apply_strafe():
	if is_on_wall():
		VELOCITY.x = 0
	elif is_on_floor():
		if should_move_left():
			VELOCITY.x = -SPEED
		elif should_move_right():
			VELOCITY.x = SPEED
		else:
			VELOCITY.x = 0
	else:
		if should_move_right() and (AIR_MOMENTUM_NORMAL == 0 or AIR_MOMENTUM_NORMAL > 0):
			VELOCITY.x = min(VELOCITY.x + AIR_STRAFE_ACCELERATION, SPEED)
		elif should_move_left() and (AIR_MOMENTUM_NORMAL == 0 or AIR_MOMENTUM_NORMAL < 0):
			VELOCITY.x = max(VELOCITY.x - AIR_STRAFE_ACCELERATION, -SPEED)
		else:
			if AIR_MOMENTUM_NORMAL > 0:
				VELOCITY.x = max(VELOCITY.x - AIR_STRAFE_RESISTANCE, 0)
			if AIR_MOMENTUM_NORMAL < 0:
				VELOCITY.x = min(VELOCITY.x + AIR_STRAFE_RESISTANCE, 0)

func set_air_momentum_normal():
	if is_on_floor():
		AIR_MOMENTUM_NORMAL = 0
	elif AIR_MOMENTUM_NORMAL == 0:
		if VELOCITY.x > 0:
			AIR_MOMENTUM_NORMAL = 1
		elif VELOCITY.x < 0:
			AIR_MOMENTUM_NORMAL = -1

func check_world_limit():
	if position.y > WORLD_LIMIT:
		get_tree().call_group("Gamestate", "game_over")

func hurt():
	jump(false)
	hurt_sfx.play()

func collect_coin(_coin):
	coin_sfx.play()

func hit_by_jump_pad(pad_power):
	VELOCITY.y = -(pad_power * JUMP_POWER)
