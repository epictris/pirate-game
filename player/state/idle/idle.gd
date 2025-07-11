extends PlayerState

func _ready() -> void:
	state_name = State.IDLE
	super()

func get_preprocess_transition(input: Dictionary) -> StateTransition:
	if input.get("up"):
		return self._transition_to(State.JUMPING)
	if input.get("left") or input.get("right"):
		return self._transition_to(State.RUNNING)
	return null

func process(_input: Dictionary):
	player.apply_gravity()
	player.move_and_slide()

func get_postprocess_transition(_input: Dictionary) -> StateTransition:
	if !player.is_on_floor():
		return self._transition_to(State.FALLING)
	return null
