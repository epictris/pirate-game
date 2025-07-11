extends PlayerState

func _ready() -> void:
	state_name = State.WALL_JUMPING
	super()

func enter(_input: Dictionary, _from_state: State, data: Dictionary = {}) -> void:
	player.velocity.y = -player.jump_velocity
	player.velocity.x = SGFixed.mul(data["wall_normal"], player.jump_velocity)

func process(input: Dictionary):
	player.velocity.y -= player.jump_gravity
	player._apply_air_acceleration(input)
	player.move_and_slide()

func get_postprocess_transition(_input: Dictionary) -> StateTransition:
	if player.velocity.y > 0:
		return self._transition_to(State.FALLING)
	if player.is_on_wall():
		return self._transition_to(
			State.WALL_SLIDING,
			{
				"wall_normal": player.get_last_slide_collision().normal.x
			}
		)
	return null
