extends PlayerState

func _ready() -> void:
	state_name = State.FALLING
	super()

func process(input: Dictionary) -> void:
	player.apply_gravity()
	player._apply_air_acceleration(input)
	player.move_and_slide()

func get_postprocess_transition(_input: Dictionary) -> StateTransition:
	if player.is_on_floor():
		if player.velocity.x == 0:
			return self._transition_to(State.IDLE)
		else:
			return self._transition_to(State.RUNNING)
	elif player.is_on_wall():
		return self._transition_to(
			State.WALL_SLIDING, 
			{
				"wall_normal": player.get_last_slide_collision().normal.x
			}
		)
	return null
