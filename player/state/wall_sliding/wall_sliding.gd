extends PlayerState

var _touching_wall_normal: int

func _ready() -> void:
	state_name = State.WALL_SLIDING
	super()

func enter(_input: Dictionary, _from_state: State, data: Dictionary = {}) -> void:
	_touching_wall_normal = data["wall_normal"]

func get_preprocess_transition(input: Dictionary) -> StateTransition:
	if input.get("up_just_pressed"):
		return self._transition_to(State.WALL_JUMPING, {"wall_normal": _touching_wall_normal})
	if input.get("down"):
		return self._transition_to(State.FALLING)
	if player.get_x_input(input) * _touching_wall_normal > 0:
		return self._transition_to(State.FALLING)
	return null

func process(_input: Dictionary):
	if player.velocity.y < 0:
		player.velocity.y -= player.jump_gravity
	else:
		player.velocity.y -= player.WALL_FRICTION
		player.velocity.y = max(player.velocity.y, player.WALL_SLIDE_SPEED)

	player.velocity.x = -_touching_wall_normal # small x velocity to ensure is_on_wall() resolves to true
	player.move_and_slide()

func get_postprocess_transition(_input: Dictionary) -> StateTransition:
	if player.is_on_floor():
		return self._transition_to(State.IDLE)
	elif !player.is_on_wall():
		# IMPROVE: should not be setting values in this function
		player.velocity.x = 0
		return self._transition_to(State.FALLING)
	return null
