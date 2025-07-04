extends SGCharacterBody2D

const SPEED = FI.ONE * 45
const GRAVITY = FI.ONE * 3

@onready var sprite: Sprite2D = %Sprite
	
var _direction: SGFixedVector2

func _network_spawn(data: Dictionary) -> void:
	fixed_position.x = data["fixed_position_x"]
	fixed_position.y = data["fixed_position_y"]
	_direction = SGFixed.vector2(data["direction"].x, data["direction"].y)
	velocity = _direction.mul(SPEED)
	sync_to_physics_engine()
	collision_mask = 0
	collision_layer = 0
	if _direction.x < 0:
		sprite.flip_h = true

func _update() -> void:
	collision_mask = 1
	collision_mask = 1
	sprite.rotate(0.1 if _direction.x > 0 else -0.1)
	velocity.y += GRAVITY
	var collision = move_and_collide(velocity)
	if collision:
		if collision.collider.has_meta("resolve_collision"):
			collision.collider.get_meta("resolve_collision").call({"collider": self})
		else:
			SyncManager.despawn(self)

func _load_state(state: Dictionary) -> void:
	fixed_position_x = state["fixed_position_x"]
	fixed_position_y = state["fixed_position_y"]
	velocity.x = state["velocity_x"]
	velocity.y = state["velocity_y"]
	rotation = state["_rotation"]
	sync_to_physics_engine()

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	position.x = lerp(SGFixed.to_float(old_state.fixed_position_x), SGFixed.to_float(new_state.fixed_position_x), weight)
	position.y = lerp(SGFixed.to_float(old_state.fixed_position_y), SGFixed.to_float(new_state.fixed_position_y), weight)
	rotation = lerp_angle(old_state._rotation, new_state._rotation, weight)

func _save_state() -> Dictionary:
	var state: Dictionary = {
		fixed_position_x = fixed_position_x,
		fixed_position_y = fixed_position_y,
		velocity_x = velocity.x,
		velocity_y = velocity.y,
		_rotation = rotation,
	}
	return state
