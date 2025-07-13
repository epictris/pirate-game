extends PlayerState

func _ready() -> void:
	state_name = State.SLIDING
	super()


func enter(_input: Dictionary, _from_state: State, _data: Dictionary = {}) -> void:
	player.sliding_collision_shape.disabled = false
	player.standing_collision_shape.disabled = true
	player.sync_to_physics_engine()

func exit(_to_state: State, _data: Dictionary = {}) -> void:
	player.sliding_collision_shape.disabled = true
	player.standing_collision_shape.disabled = false
	player.sync_to_physics_engine()

func get_preprocess_transition(input: Dictionary) -> StateTransition:
	if input.get("up"):
		return self._transition_to(State.JUMPING)
	if input.get("down"):
		return null
	if input.get("left") or input.get("right"):
		return self._transition_to(State.RUNNING)
	return null


func process(_input: Dictionary):
	player.apply_gravity()
	player.apply_slide_friction()
	player.move_and_slide()

func get_postprocess_transition(input: Dictionary) -> StateTransition:
	if !player.is_on_floor():
		return self._transition_to(State.FALLING)
	if !input.get("down"):
		if player.velocity.x == 0:
			return self._transition_to(State.IDLE)
		else:
			return self._transition_to(State.RUNNING)
	return null
