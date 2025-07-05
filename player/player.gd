class_name Player extends SGCharacterBody2D

const MAX_SPEED = FI.ONE * 12
const WALL_SLIDE_SPEED = FI.ONE_POINT_FIVE
const WALL_FRICTION = FI.ONE_POINT_FIVE
const GROUND_ACCEL = FI.ONE * 3
const GROUND_FRICTION = FI.ONE_POINT_ONE
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

var _is_on_floor: bool = false
var _is_on_ceiling: bool = false
var _is_on_wall: bool = false

var _touching_wall_normal: int

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

var _current_ability: AbilityBase

@onready var state_machine: PlayerState = %States

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


func activate_ability(ability: AbilityBase, allow_overwrite: bool = false) -> void:
	assert(allow_overwrite or !_current_ability, "Attempting to activate an ability while an ability is already active")
	_current_ability = ability

func deactivate_ability(ability: AbilityBase) -> void:
	assert(_current_ability == ability, "Attempting to deactivate ability that is not currently active")
	_current_ability = null

func has_active_ability() -> bool:
	return true if _current_ability else false

func is_ability_active(ability: AbilityBase) -> bool:
	return ability == _current_ability

func _get_local_input() -> Dictionary:

	var input := {
		up = Input.is_action_pressed("ui_up"),
		up_just_pressed = Input.is_action_just_pressed("ui_up"),
		down = Input.is_action_pressed("ui_down"),
		left = Input.is_action_pressed("ui_left"),
		right = Input.is_action_pressed("ui_right"),
	}

	if Input.is_action_just_pressed("left_click"):
		var direction = SGFixed.from_float_vector2(position.direction_to(get_viewport().get_mouse_position()))
		input["primary_activated"] = SGFixed.vector2(direction.x, direction.y)

	if Input.is_action_pressed("left_click"):
		var direction = SGFixed.from_float_vector2(position.direction_to(get_viewport().get_mouse_position()))
		input["primary_updated"] = SGFixed.vector2(direction.x, direction.y)

	if Input.is_action_just_released("left_click"):
		var direction = SGFixed.from_float_vector2(position.direction_to(get_viewport().get_mouse_position()))
		input["primary_deactivated"] = SGFixed.vector2(direction.x, direction.y)

	if Input.is_action_just_pressed("right_click"):
		var direction = SGFixed.from_float_vector2(position.direction_to(get_viewport().get_mouse_position()))
		input["secondary_activated"] = SGFixed.vector2(direction.x, direction.y)

	if Input.is_action_pressed("right_click"):
		var direction = SGFixed.from_float_vector2(position.direction_to(get_viewport().get_mouse_position()))
		input["secondary_updated"] = SGFixed.vector2(direction.x, direction.y)

	if Input.is_action_just_released("right_click"):
		var direction = SGFixed.from_float_vector2(position.direction_to(get_viewport().get_mouse_position()))
		input["secondary_deactivated"] = SGFixed.vector2(direction.x, direction.y)

	return input

func _network_preprocess(input: Dictionary) -> void:
	frame_input = input

func _preprocess_ability_input(input: Dictionary) -> void:
	if ability_primary:
		if !_current_ability and input.get("primary_activated") and ability_primary.has_method("_preprocess_on_activated"):
			ability_primary._preprocess_on_activated(input["primary_activated"])
		if !_current_ability and input.get("primary_updated") and ability_primary.has_method("_preprocess_on_activated"):
			# Treat update as activation input if no ability is active
			ability_primary._preprocess_on_activated(input["primary_updated"])
		if _current_ability == ability_primary:
			if input.get("primary_updated") and ability_primary.has_method("_preprocess_on_updated"):
				ability_primary._preprocess_on_updated(input["primary_updated"])
			if input.get("primary_deactivated") and ability_primary.has_method("_preprocess_on_deactivated"):
				ability_primary._preprocess_on_deactivated(input["primary_deactivated"])

	if ability_secondary:
		if !_current_ability and input.get("secondary_activated") and ability_secondary.has_method("_preprocess_on_activated"):
			ability_secondary._preprocess_on_activated(input["secondary_activated"])
		if !_current_ability and input.get("secondary_updated") and ability_secondary.has_method("_preprocess_on_activated"):
			# Treat update as activation input if no ability is active
			ability_secondary._preprocess_on_activated(input["secondary_updated"])
		if _current_ability == ability_secondary:
			if input.get("secondary_updated") and ability_secondary.has_method("_preprocess_on_updated"):
				ability_secondary._preprocess_on_updated(input["secondary_updated"])
			if input.get("secondary_deactivated") and ability_secondary.has_method("_preprocess_on_deactivated"):
				ability_secondary._preprocess_on_deactivated(input["secondary_deactivated"])

func _postprocess_ability_input(input: Dictionary) -> void:
	if ability_primary:
		if (!_current_ability or _current_ability == ability_primary) and input.get("primary_activated") and ability_primary.has_method("_postprocess_on_activated"):
			ability_primary._postprocess_on_activated(input["primary_activated"])
		if !_current_ability and input.get("primary_updated") and ability_primary.has_method("_postprocess_on_activated"):
			# Treat update as activation input if no ability is active
			ability_primary._postprocess_on_activated(input["primary_updated"])
		if _current_ability == ability_primary:
			if input.get("primary_updated") and ability_primary.has_method("_postprocess_on_updated"):
				ability_primary._postprocess_on_updated(input["primary_updated"])
			if input.get("primary_deactivated") and ability_primary.has_method("_postprocess_on_deactivated"):
				ability_primary._postprocess_on_deactivated(input["primary_deactivated"])

	if ability_secondary:
		if (!_current_ability or _current_ability == ability_secondary) and input.get("secondary_activated") and ability_secondary.has_method("_postprocess_on_activated"):
			ability_secondary._postprocess_on_activated(input["secondary_activated"])
		if !_current_ability and input.get("secondary_updated") and ability_secondary.has_method("_postprocess_on_activated"):
			# Treat update as activation input if no ability is active
			ability_secondary._postprocess_on_activated(input["secondary_updated"])
		if _current_ability == ability_secondary:
			if input.get("secondary_updated") and ability_secondary.has_method("_postprocess_on_updated"):
				ability_secondary._postprocess_on_updated(input["secondary_updated"])
			if input.get("secondary_deactivated") and ability_secondary.has_method("_postprocess_on_deactivated"):
				ability_secondary._postprocess_on_deactivated(input["secondary_deactivated"])

func _update() -> void:
	_process_tick(frame_input)

func _process_tick(input: Dictionary) -> void:
	_preprocess_ability_input(input)

	var override_movement: bool = false

	if _current_ability:
		if _current_ability.has_method("_hook_before_player_movement"):
			_current_ability._hook_before_player_movement()

		if _current_ability.has_method("_should_override_movement"):
			override_movement = _current_ability._should_override_movement()

	if !override_movement:
		state_machine.process_tick(input)

	if _current_ability:
		if _current_ability.has_method("_hook_after_player_movement"):
			_current_ability._hook_after_player_movement()
	
	_postprocess_ability_input(input)

func _save_state() -> Dictionary:
	var state: Dictionary = {
		fixed_position_x = fixed_position_x,
		fixed_position_y = fixed_position_y,
		velocity_x = velocity.x,
		velocity_y = velocity.y,
		is_on_floor = _is_on_floor,
		is_on_ceiling = _is_on_ceiling,
		is_on_wall = _is_on_wall,
		touching_wall_normal = _touching_wall_normal,
		max_speed = current_max_speed,
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
	_touching_wall_normal = state["touching_wall_normal"]
	current_max_speed = state["max_speed"]
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
