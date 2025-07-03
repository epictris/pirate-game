extends SGArea2D

func _network_spawn(data: Dictionary) -> void:
	fixed_rotation = data["rotation"]

func _save_state() -> Dictionary:
	return {
		fixed_rotation = fixed_rotation
	}

func _load_state(state: Dictionary) -> void:
	fixed_rotation = state["fixed_rotation"]
	sync_to_physics_engine()

func _network_process(input: Dictionary) -> void:
	for body in get_overlapping_bodies():
		if body.has_method("rebound"):
			var shield_direction = SGFixed.vector2(-FI.ONE, 0).rotated(fixed_rotation)
			body.rebound(shield_direction)
	sync_to_physics_engine() # need to call here because position is not automatically synced when parent moves

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	var old_rotation = SGFixed.to_float(old_state.fixed_rotation)
	var new_rotation = SGFixed.to_float(new_state.fixed_rotation)
	rotation = lerp_angle(old_rotation, new_rotation, weight)

func get_velocity() -> SGFixedVector2:
	return get_parent().get_velocity()
