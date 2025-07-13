class_name Player extends SGCharacterBody2D

const MAX_SPEED = FI.ONE * 12
const WALL_SLIDE_SPEED = FI.ONE_POINT_FIVE
const WALL_FRICTION = FI.ONE_POINT_FIVE
const GROUND_ACCEL = FI.ONE * 3
const GROUND_FRICTION = FI.ONE_POINT_ONE
var SLIDE_FRICTION = FI.POINT_FOUR
const AIR_ACCEL = FI.POINT_FOUR
const GRAVITY = FI.ONE * 2
const JUMP = FI.ONE * 10

var current_max_speed: int = MAX_SPEED

func override_max_speed(new_max_speed: int) -> void:
	current_max_speed = new_max_speed

func reset_max_speed() -> void:
	current_max_speed = MAX_SPEED

@export var jump_height: int
@export var jump_time_to_peak: int
@export var jump_time_to_descent: int

@export var ability_primary: AbilityBase
@export var ability_secondary: AbilityBase
@export var ability_special: AbilityBase

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

@onready var standing_collision_shape: SGCollisionShape2D = %StandingCollisionShape
@onready var sliding_collision_shape: SGCollisionShape2D = %SlidingCollisionShape

var _is_on_floor: bool = false
var _is_on_ceiling: bool = false
var _is_on_wall: bool = false

enum MovementState {
	IDLE,
	RUNNING,	
	JUMPING,
	FALLING,
	WALL_JUMPING,
	WALL_SLIDING,
}

var frame_input: Dictionary = {}

var spawn_position: SGFixedVector2

@onready var state_machine: PlayerStateMachine = %States
@onready var ability_manager: AbilityManager = %Abilities
@onready var animation_manager: AnimationManager = %AnimationManager

func _ready():
	collision_layer = CollisionLayer.PLAYERS
	collision_mask = CollisionLayer.PLAYERS | CollisionLayer.ENVIRONMENT
	respawn()

func respawn() -> void:
	fixed_position_x = spawn_position.x
	fixed_position_y = spawn_position.y
	velocity.x = 0
	velocity.y = 0
	sync_to_physics_engine()

func _get_local_input() -> Dictionary:

	var input := {
		up = Input.is_action_pressed("jump"),
		up_just_pressed = Input.is_action_just_pressed("jump"),
		down = Input.is_action_pressed("move_down"),
		left = Input.is_action_pressed("move_left"),
		right = Input.is_action_pressed("move_right"),
	}

	if Input.is_action_just_pressed("left_click"):
		var direction = SGFixed.from_float_vector2(position.direction_to(get_viewport().get_mouse_position()))
		input["primary_activated"] = true
		input["direction"] = {
			x =  direction.x, 
			y = direction.y
		}

	if Input.is_action_pressed("left_click"):
		var direction = SGFixed.from_float_vector2(position.direction_to(get_viewport().get_mouse_position()))
		input["primary_updated"] = true
		input["direction"] = {
			x =  direction.x, 
			y = direction.y
		}

	if Input.is_action_just_released("left_click"):
		var direction = SGFixed.from_float_vector2(position.direction_to(get_viewport().get_mouse_position()))
		input["primary_deactivated"] = true
		input["direction"] = {
			x =  direction.x, 
			y = direction.y
		}

	if Input.is_action_just_pressed("right_click"):
		var direction = SGFixed.from_float_vector2(position.direction_to(get_viewport().get_mouse_position()))
		input["secondary_activated"] = true
		input["direction"] = {
			x =  direction.x, 
			y = direction.y
		}

	if Input.is_action_pressed("right_click"):
		var direction = SGFixed.from_float_vector2(position.direction_to(get_viewport().get_mouse_position()))
		input["secondary_updated"] = true
		input["direction"] = {
			x =  direction.x, 
			y = direction.y
		}

	if Input.is_action_just_released("right_click"):
		var direction = SGFixed.from_float_vector2(position.direction_to(get_viewport().get_mouse_position()))
		input["secondary_deactivated"] = true
		input["direction"] = {
			x =  direction.x, 
			y = direction.y
		}

	return input

func _network_preprocess(input: Dictionary) -> void:
	frame_input = input
	if frame_input.has("direction"):
		frame_input["direction"] = SGFixed.vector2(frame_input["direction"].x, frame_input["direction"].y)


func _update() -> void:
	_process_tick(frame_input)

func _process_tick(input: Dictionary) -> void:
	ability_manager.preprocess_ability(input)

	if !ability_manager.should_override_movement():
		state_machine.process_tick(input)

	ability_manager.postprocess_ability(input)

	animation_manager.update_animation(input)

func _save_state() -> Dictionary:
	var state: Dictionary = {
		fixed_position_x = fixed_position_x,
		fixed_position_y = fixed_position_y,
		velocity_x = velocity.x,
		velocity_y = velocity.y,
		is_on_floor = _is_on_floor,
		is_on_ceiling = _is_on_ceiling,
		is_on_wall = _is_on_wall,
		max_speed = current_max_speed,
		standing_shape_disabled = standing_collision_shape.disabled,
		sliding_shape_disabled = sliding_collision_shape.disabled,
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
	current_max_speed = state["max_speed"]
	standing_collision_shape.disabled = state["standing_shape_disabled"]
	sliding_collision_shape.disabled = state["sliding_shape_disabled"]
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

func _apply_ground_friction() -> void:
	if velocity.x > 0:
		velocity.x = max(velocity.x - GROUND_FRICTION, 0)
	elif velocity.x < 0:
		velocity.x = min(velocity.x + GROUND_FRICTION, 0)

func apply_slide_friction() -> void:
	if velocity.x > 0:
		velocity.x = max(velocity.x - SLIDE_FRICTION, 0)
	elif velocity.x < 0:
		velocity.x = min(velocity.x + SLIDE_FRICTION, 0)

func apply_gravity() -> void:
	velocity.y -= fall_gravity

func _apply_air_acceleration(input: Dictionary) -> void:
	var x_acceleration = SGFixed.mul(get_x_input(input), AIR_ACCEL)
	if velocity.x * x_acceleration > 0: # if we're accelerating in the same direction we are moving
		var allowed_acceleration = max(current_max_speed - abs(velocity.x), 0)
		var actual_acceleration = min(allowed_acceleration, abs(x_acceleration))
		if x_acceleration > 0:
			velocity.x += actual_acceleration
		else:
			velocity.x -= actual_acceleration
	else:
		velocity.x += x_acceleration

func get_x_input(input: Dictionary) -> int:
	var right_motion: int = SGFixed.ONE if input.get("right") else 0
	var left_motion: int = SGFixed.NEG_ONE if input.get("left") else 0
	return right_motion + left_motion
