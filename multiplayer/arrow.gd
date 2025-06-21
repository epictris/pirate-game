extends SGArea2D

const SPEED = 65536 * 20

var velocity: SGFixedVector2 = SGFixed.vector2(0, 0)
var owner_node_path: String

func _network_spawn(data: Dictionary) -> void:
	fixed_position_x = data["fixed_position_x"]
	fixed_position_y = data["fixed_position_y"]
	fixed_rotation = data["fixed_rotation"]
	owner_node_path = data["owner_node_path"]
	var direction: SGFixedVector2 = SGFixed.vector2(SGFixed.ONE, 0).rotated(fixed_rotation)
	velocity = direction.mul(-SPEED)

func _network_process(input: Dictionary) -> void:
	fixed_position_x += velocity.x
	fixed_position_y += velocity.y

	for body in get_overlapping_bodies():
		if str(body.get_path()) != owner_node_path:
			if body.has_method("take_damage"):
				body.take_damage()
			SyncManager.despawn(self)

	sync_to_physics_engine()

func _save_state() -> Dictionary:
	var state: Dictionary = {
		fixed_position_x = fixed_position_x,
		fixed_position_y = fixed_position_y,
		velocity_x = velocity.x,
		velocity_y = velocity.y,
	}
	return state

func _load_state(state: Dictionary) -> void:
	fixed_position_x = state["fixed_position_x"]
	fixed_position_y = state["fixed_position_y"]
	velocity.x = state["velocity_x"]
	velocity.y = state["velocity_y"]

	sync_to_physics_engine()
