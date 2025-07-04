extends Node

func preprocess_state_transition(input, player: Player) -> PlayerState.MovementState:
	if input.get("up_just_pressed"):
		return PlayerState.MovementState.WALL_JUMPING
	if input.get("down"):
		return PlayerState.MovementState.FALLING
	if player.get_x_input(input) * player._touching_wall_normal > 0:
		return PlayerState.MovementState.FALLING
	return PlayerState.MovementState.WALL_SLIDING

func process_state(_input: Dictionary, player: Player):
	if player.velocity.y < 0:
		player.velocity.y -= player.jump_gravity
	else:
		player.velocity.y -= player.WALL_FRICTION
		player.velocity.y = max(player.velocity.y, player.WALL_SLIDE_SPEED)

	player.velocity.x = -player._touching_wall_normal # small x velocity to ensure is_on_wall() resolves to true
	player.move_and_slide()

func postprocess_state_transition(player: Player) -> PlayerState.MovementState:
	if player.is_on_floor():
		return PlayerState.MovementState.IDLE
	elif !player.is_on_wall():
		# IMPROVE: should not be setting values in this function
		player.velocity.x = 0
		return PlayerState.MovementState.FALLING
	return PlayerState.MovementState.WALL_SLIDING
