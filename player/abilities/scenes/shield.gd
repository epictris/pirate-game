extends SGArea2D

func _network_spawn(data: Dictionary) -> void:
	fixed_rotation = data["rotation"]

func take_damage() -> void:
	pass

func _save_state() -> Dictionary:
	return {
		fixed_rotation = fixed_rotation
	}

func _load_state(state: Dictionary) -> void:
	fixed_rotation = state["fixed_rotation"]
	sync_to_physics_engine()

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	var old_rotation = SGFixed.to_float(old_state.fixed_rotation)
	var new_rotation = SGFixed.to_float(new_state.fixed_rotation)
	rotation = lerp_angle(old_rotation, new_rotation, weight)
