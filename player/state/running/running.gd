extends PlayerState

func _ready() -> void:
	state_name = State.RUNNING
	super()

func get_preprocess_transition(input: Dictionary) -> StateTransition:
	if input.get("up"):
		return self._transition_to(State.JUMPING)
	if input.get("down"):
		return self._transition_to(State.SLIDING)
	return null

func process(input: Dictionary):
	var right_motion: int = SGFixed.ONE if input.get("right") else 0
	var left_motion: int = SGFixed.NEG_ONE if input.get("left") else 0

	player.apply_gravity()

	if !right_motion and !left_motion:
		player._apply_ground_friction()

	player.velocity.x += SGFixed.mul(right_motion + left_motion, player.GROUND_ACCEL)
	player.velocity.x = clamp(player.velocity.x, -player.current_max_speed, player.current_max_speed)

	player.move_and_slide()


func get_postprocess_transition(input: Dictionary) -> StateTransition:
	if !player.is_on_floor():
		return self._transition_to(State.FALLING)
	elif player.velocity.x == 0:
		if !(input.get("right") or input.get("left")) or player.is_on_wall():
			return self._transition_to(State.IDLE)
	return null
