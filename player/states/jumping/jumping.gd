extends Node

func enter(player: Player) -> void:
	player.velocity.y -= player.jump_velocity

func preprocess_state_transition(_input: Dictionary, _player: Player) -> PlayerState.MovementState:
	return PlayerState.MovementState.JUMPING

func process_state(input: Dictionary, player: Player):
	player.velocity.y -= player.jump_gravity
	player._apply_air_acceleration(input)
	player.move_and_slide()

func postprocess_state_transition(player: Player) -> PlayerState.MovementState:
	if player.velocity.y > 0:
		return PlayerState.MovementState.FALLING
	if player.is_on_wall():
		# IMPROVE: should not be setting values in this function
		player._touching_wall_normal = player.get_last_slide_collision().normal.x
		return PlayerState.MovementState.WALL_SLIDING
	return PlayerState.MovementState.JUMPING
