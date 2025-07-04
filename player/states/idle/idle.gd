extends Node

func enter() -> void:
	pass

func exit() -> void:
	pass

func preprocess_state_transition(input, _player) -> PlayerState.MovementState:
	if input.get("up"):
		return PlayerState.MovementState.JUMPING
	if input.get("left") or input.get("right"):
		return PlayerState.MovementState.RUNNING
	return PlayerState.MovementState.IDLE

func process_state(_input: Dictionary, player: Player):
	player.apply_gravity()
	player.move_and_slide()

func postprocess_state_transition(player: Player) -> PlayerState.MovementState:
	if !player.is_on_floor():
		return PlayerState.MovementState.FALLING
	return PlayerState.MovementState.IDLE
