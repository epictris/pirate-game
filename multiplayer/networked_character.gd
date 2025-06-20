extends SGCharacterBody2D

const MAX_SPEED = 65536 * 10
const WALL_SLIDE_SPEED = 65536 * 2
const WALL_FRICTION = 65536
const GROUND_ACCEL = 65536 * 2
const GROUND_FRICTION = 65536
const AIR_ACCEL = SGFixed.HALF
const GRAVITY = 65536 * 2
const JUMP = 65536 * 30

@export var jump_height: int
@export var jump_time_to_peak: int
@export var jump_time_to_descent: int

@onready var jump_velocity: int = SGFixed.div(
	SGFixed.mul(
		SGFixed.TWO, 
		jump_height * SGFixed.ONE
	), 
	jump_time_to_peak * SGFixed.ONE
)
@onready var jump_gravity: int = SGFixed.div(
	SGFixed.mul(
		-SGFixed.TWO, 
		jump_height * SGFixed.ONE
	), 
	SGFixed.mul(
		jump_time_to_peak * SGFixed.ONE, 
		jump_time_to_peak * SGFixed.ONE
	)
)
@onready var fall_gravity: int = SGFixed.div(
	SGFixed.mul(
		-SGFixed.TWO, 
		jump_height * SGFixed.ONE
	), 
	SGFixed.mul(
		jump_time_to_descent * SGFixed.ONE, 
		jump_time_to_descent * SGFixed.ONE
	)
)

var _is_on_floor: bool = false
var _is_on_ceiling: bool = false
var _is_on_wall: bool = false

var _touching_wall_normal: int

var _player_state: PlayerState = PlayerState.IDLE
var _buffered_jump_input: bool = false

enum PlayerState {
	IDLE,
	RUNNING,	
	JUMPING,
	FALLING,
	WALL_JUMPING,
	WALL_SLIDING,
}


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_up"):
			_buffered_jump_input = true


func _get_local_input() -> Dictionary:
	var input := {
		up = _buffered_jump_input or Input.is_action_pressed("ui_up"),
		up_just_pressed = _buffered_jump_input or Input.is_action_just_pressed("ui_up"),
		down = Input.is_action_pressed("ui_down"),
		left = Input.is_action_pressed("ui_left"),
		right = Input.is_action_pressed("ui_right"),
	}
	_buffered_jump_input = false

	return input

func _update_player_velocity() -> void:

	if _player_state == PlayerState.JUMPING:
		if _is_on_floor:
			velocity.y -= jump_velocity
		elif velocity.y < 0:
			velocity.y -= jump_gravity
		else:
			_player_state = PlayerState.FALLING
	elif _player_state == PlayerState.WALL_JUMPING:
		if _is_on_wall:
			velocity.y = -jump_velocity
			var wall_jump_direction = _touching_wall_normal
			velocity.x = SGFixed.mul(wall_jump_direction, jump_velocity)
			_player_state = PlayerState.JUMPING
	elif _player_state == PlayerState.WALL_SLIDING:
		if velocity.y < 0:
			velocity.y -= jump_gravity
		else:
			velocity.y -= WALL_FRICTION
			velocity.y = max(velocity.y, WALL_SLIDE_SPEED)
	else:
		velocity.y -= fall_gravity

func _network_process(input: Dictionary) -> void:

	var right_motion: int = SGFixed.ONE if input.get("right") else 0
	var left_motion: int = SGFixed.NEG_ONE if input.get("left") else 0

	# apply friction force
	if _is_on_floor:
		if !right_motion and !left_motion:
			if velocity.x > 0:
				velocity.x = velocity.x - GROUND_FRICTION
			elif velocity.x < 0:
				velocity.x = velocity.x + GROUND_FRICTION

	# apply air or ground acceleration
	if _is_on_floor or _is_on_wall:
		velocity.x += SGFixed.mul(right_motion + left_motion, GROUND_ACCEL)
	else:
		velocity.x += SGFixed.mul(right_motion + left_motion, AIR_ACCEL)
	velocity.x = clampi(velocity.x, -MAX_SPEED, MAX_SPEED)


	if _is_on_floor:
		if input.get("up_just_pressed"):
			_player_state = PlayerState.JUMPING
		elif velocity.x != 0:
			_player_state = PlayerState.RUNNING
		else:
			_player_state = PlayerState.IDLE

	elif _is_on_wall:
		if input.get("up_just_pressed"):
			_player_state = PlayerState.WALL_JUMPING
		elif input.get("right") and _touching_wall_normal < 0:
			_player_state = PlayerState.WALL_SLIDING
		elif input.get("left") and _touching_wall_normal > 0:
			_player_state = PlayerState.WALL_SLIDING

	elif !_player_state == PlayerState.JUMPING:
		_player_state = PlayerState.FALLING

	_update_player_velocity()

	move_and_slide()

	_is_on_floor = is_on_floor()
	_is_on_ceiling = is_on_ceiling()

	if is_on_wall():
		_touching_wall_normal = get_last_slide_collision().normal.x
		_is_on_wall = true
	else:
		_is_on_wall = false


func _save_state() -> Dictionary:
	return {
		fixed_position_x = fixed_position_x,
		fixed_position_y = fixed_position_y,
		velocity_x = velocity.x,
		velocity_y = velocity.y,
		is_on_floor = _is_on_floor,
		is_on_ceiling = _is_on_ceiling,
		is_on_wall = _is_on_wall,
		player_state = _player_state,
		touching_wall_normal = _touching_wall_normal,
	}

func _load_state(state: Dictionary) -> void:
	fixed_position_x = state["fixed_position_x"]
	fixed_position_y = state["fixed_position_y"]
	velocity.x = state["velocity_x"]
	velocity.y = state["velocity_y"]
	_is_on_floor = state["is_on_floor"]
	_is_on_ceiling = state["is_on_ceiling"]
	_is_on_wall = state["is_on_wall"]
	_player_state = state["player_state"]
	_touching_wall_normal = state["touching_wall_normal"]
	sync_to_physics_engine()

func _predict_remote_input(previous_input: Dictionary, ticks_since_last_input: int) -> Dictionary:
	var input = previous_input.duplicate()

	if ticks_since_last_input > 2:
		input.erase("left")
		input.erase("right")
	return input
