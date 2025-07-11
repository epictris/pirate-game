extends PlayerState

func _ready() -> void:
	state_name = State.SLIDING
	super()


func enter(_input: Dictionary, _from_state: State, _data: Dictionary = {}) -> void:
	player.collision_shape.shape.extents.x = 65536 * 25
	player.collision_shape.shape.extents.y = 65536 * 10
	player.collision_shape.fixed_position.y += 65536 * 14
	player.sync_to_physics_engine()

func exit(_to_state: State, _data: Dictionary = {}) -> void:
	player.collision_shape.shape.extents.x = 65536 * 10
	player.collision_shape.shape.extents.y = 65536 * 25
	player.collision_shape.fixed_position.y -= 65536 * 14
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
