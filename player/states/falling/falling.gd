extends Node

func preprocess_state_transition(_input, _player) -> PlayerState.MovementState:
	return PlayerState.MovementState.FALLING

func process_state(input: Dictionary, player: Player):
	player.apply_gravity()
	player._apply_air_acceleration(input)
	player.move_and_slide()

func postprocess_state_transition(player: Player) -> PlayerState.MovementState:
	if player.is_on_floor():
		if player.velocity.x == 0:
			return PlayerState.MovementState.IDLE
		else:
			return PlayerState.MovementState.RUNNING
	elif player.is_on_wall():
		# IMPROVE: should not be setting values in this function
		player._touching_wall_normal = player.get_last_slide_collision().normal.x
		return PlayerState.MovementState.WALL_SLIDING
	return PlayerState.MovementState.FALLING
