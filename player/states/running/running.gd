extends Node

func preprocess_state_transition(input, _player) -> PlayerState.MovementState:
	if input.get("up"):
		return PlayerState.MovementState.JUMPING
	return PlayerState.MovementState.RUNNING

func process_state(input: Dictionary, player: Player):
	var right_motion: int = SGFixed.ONE if input.get("right") else 0
	var left_motion: int = SGFixed.NEG_ONE if input.get("left") else 0

	player.apply_gravity()

	if !right_motion and !left_motion:
		player._apply_ground_friction()

	player.velocity.x += SGFixed.mul(right_motion + left_motion, player.GROUND_ACCEL)
	player.velocity.x = clamp(player.velocity.x, -player.current_max_speed, player.current_max_speed)

	player.move_and_slide()

func postprocess_state_transition(player: Player) -> PlayerState.MovementState:
	if !player.is_on_floor():
		return PlayerState.MovementState.FALLING
	elif player.velocity.x == 0:
		return PlayerState.MovementState.IDLE
	return PlayerState.MovementState.RUNNING
