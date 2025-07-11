extends PlayerState

func _ready() -> void:
	state_name = State.JUMPING
	super()

func enter(input: Dictionary, _from_state: State, _data: Dictionary = {}) -> void:
	player.velocity.y -= player.jump_velocity
	if input.get("left"):
		player.velocity.x -= SGFixed.div(player.MAX_SPEED, SGFixed.ONE * 10)
	elif input.get("right"):
		player.velocity.x += SGFixed.div(player.MAX_SPEED, SGFixed.ONE * 10)

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
