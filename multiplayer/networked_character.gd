extends SGCharacterBody2D

var arrow: PackedScene = preload("res://multiplayer/arrow.tscn")
var bouncy_ball: PackedScene = preload("res://multiplayer/bouncy_ball.tscn")

const F0_1 = 6553
const F0_2 = 6553 * 2
const F0_3 = 6553 * 3
const F0_4 = 6553 * 4
const F0_5 = 6553 * 5
const F0_6 = 6553 * 6
const F0_7 = 6553 * 7
const F0_8 = 6553 * 8
const F0_9 = 6553 * 9
const F1 = 65536
const F1_1 = F1 + F0_1
const F1_2 = F1 + F0_2
const F1_3 = F1 + F0_3
const F1_4 = F1 + F0_4
const F1_5 = F1 + F0_5
const F1_6 = F1 + F0_6
const F1_7 = F1 + F0_7
const F1_8 = F1 + F0_8
const F1_9 = F1 + F0_9
const F2 = F1 * 2

const MAX_SPEED = 65536 * 8 * 2
const WALL_SLIDE_SPEED = 65536 * 2 * 2
const WALL_FRICTION = 65536 * 2
const GROUND_ACCEL = 65536 * 3 * 2
const GROUND_FRICTION = 65536 + F1_2
const AIR_ACCEL = F0_4 * 2
const GRAVITY = 65536 * 2 * 2
const JUMP = 65536 * 10 * 2

@export var jump_height: int
@export var jump_time_to_peak: int
@export var jump_time_to_descent: int

var spawn_location_x: int
var spawn_location_y: int

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

enum PlayerState {
	IDLE,
	RUNNING,	
	JUMPING,
	FALLING,
	WALL_JUMPING,
	WALL_SLIDING,
}

var spawn_position: SGFixedVector2

func _ready():
	respawn()

func respawn() -> void:
	fixed_position_x = spawn_position.x
	fixed_position_y = spawn_position.y
	velocity.x = 0
	velocity.y = 0
	sync_to_physics_engine()

func _get_local_input() -> Dictionary:
	var input := {
		up = Input.is_action_pressed("ui_up"),
		up_just_pressed = Input.is_action_just_pressed("ui_up"),
		down = Input.is_action_pressed("ui_down"),
		left = Input.is_action_pressed("ui_left"),
		right = Input.is_action_pressed("ui_right"),
	}

	if Input.is_action_just_pressed("attack"):
		input["mouse_click_x"] = SGFixed.from_float(get_viewport().get_mouse_position().x)
		input["mouse_click_y"] = SGFixed.from_float(get_viewport().get_mouse_position().y)
	
	if Input.is_action_just_pressed("alt_attack"):
		input["right_mouse_click_x"] = SGFixed.from_float(get_viewport().get_mouse_position().x)
		input["right_mouse_click_y"] = SGFixed.from_float(get_viewport().get_mouse_position().y)

	return input

func _update_player_velocity() -> void:
	if _player_state == PlayerState.JUMPING:
		if _is_on_floor:
			velocity.y -= jump_velocity
			velocity.x += SGFixed.mul(velocity.x, F0_2)
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

func debug_hierarchy():
	print("=== HIERARCHY DEBUG ===")
	for child in get_parent().get_children():
		print(child.name, " - ", child.get_path())
	print("=====================")

func _network_process(input: Dictionary) -> void:
	if input.get("mouse_click_x"):
		var mouse_click_position = SGFixed.vector2(input.get("mouse_click_x"), input.get("mouse_click_y"))
		var angle_to_mouse_click: int = fixed_position.angle_to_point(mouse_click_position)
		var arrow_data: Dictionary = {
			fixed_position_x = fixed_position_x,
			fixed_position_y = fixed_position_y,
			fixed_rotation = angle_to_mouse_click,
			owner_node_path = get_path(),
		}
		SyncManager.spawn("arrow", get_parent(), arrow, arrow_data)

	if input.get("right_mouse_click_x"):
		var mouse_click_position = SGFixed.vector2(input.get("right_mouse_click_x"), input.get("right_mouse_click_y"))
		var angle_to_mouse_click: int = fixed_position.angle_to_point(mouse_click_position)
		var ball_data: Dictionary = {
			fixed_position_x = fixed_position_x,
			fixed_position_y = fixed_position_y,
			fixed_rotation = angle_to_mouse_click,
		}
		SyncManager.spawn("ball", get_parent(), bouncy_ball, ball_data)

	var right_motion: int = SGFixed.ONE if input.get("right") else 0
	var left_motion: int = SGFixed.NEG_ONE if input.get("left") else 0

	# apply friction force
	if _is_on_floor:
		if !right_motion and !left_motion:
			if velocity.x > 0:
				velocity.x = max(velocity.x - GROUND_FRICTION, 0)
			elif velocity.x < 0:
				velocity.x = min(velocity.x + GROUND_FRICTION, 0)

	# apply air or ground acceleration
	if _is_on_floor or _is_on_wall:
		velocity.x += SGFixed.mul(right_motion + left_motion, GROUND_ACCEL)
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	else:
		var x_acceleration = SGFixed.mul(right_motion + left_motion, AIR_ACCEL)
		if velocity.x * x_acceleration > 0: # if we're accelerating in the same direction we are moving
			var allowed_acceleration = max(MAX_SPEED - abs(velocity.x), 0)
			velocity.x += min(x_acceleration, allowed_acceleration)
		else:
			velocity.x += x_acceleration


	if _is_on_floor:
		if input.get("up"):
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
	var state: Dictionary = {
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
	return state

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

	if ticks_since_last_input > 1:
		if _is_on_floor:
			input.erase("left")
			input.erase("right")

	if input.get("mouse_click_x"):
		input.erase("mouse_click_x")
		input.erase("mouse_click_y")

	if input.get("right_mouse_click_x"):
		input.erase("right_mouse_click_x")
		input.erase("right_mouse_click_y")

	if input.get("up_just_pressed"):
		input.erase("up_just_pressed")

	return input

func take_damage() -> void:
	respawn()

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	position.x = lerp(SGFixed.to_float(old_state.fixed_position_x), SGFixed.to_float(new_state.fixed_position_x), weight)
	position.y = lerp(SGFixed.to_float(old_state.fixed_position_y), SGFixed.to_float(new_state.fixed_position_y), weight)


