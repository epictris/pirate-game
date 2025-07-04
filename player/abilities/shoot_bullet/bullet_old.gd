extends SGCharacterBody2D

const SPEED = FI.ONE * 60

signal collided(bullet: SGCharacterBody2D, collider: SGPhysicsBody2D, position: SGFixedVector2)

var position_last_tick: SGFixedVector2

@export var explosion_scene: PackedScene

func _network_spawn(data: Dictionary) -> void:
	velocity = data.direction.mul(SPEED)
	fixed_position = data.fixed_position.add(data.direction.mul(FI.ONE * 70))
	position_last_tick = fixed_position.copy()

func _update() -> void:
	var position_next_tick = fixed_position.add(velocity)

	var ray_cast_result = SGPhysics2DServer.world_cast_ray(
		SGPhysics2DServer.get_default_world(),
		position_last_tick,
		position_next_tick.sub(position_last_tick),
		CollisionLayer.PLAYERS | CollisionLayer.ITEMS | CollisionLayer.ENVIRONMENT | CollisionLayer.PROJECTILES, [self])

	if ray_cast_result:
		collided.emit(self, ray_cast_result.collider, ray_cast_result.point)
		return

	position_last_tick = fixed_position.copy()

	var collision_result = move_and_collide(velocity)
	if collision_result:
		collided.emit(self, collision_result.collider, fixed_position.add(collision_result.remainder))

func _save_state() -> Dictionary:
	return {
		fixed_position_x = fixed_position.x,
		fixed_position_y = fixed_position.y,
		velocity_x = velocity.x,
		velocity_y = velocity.y,
	}

func _load_state(state: Dictionary) -> void:
	fixed_position.x = state["fixed_position_x"]
	fixed_position.y = state["fixed_position_y"]
	velocity.x = state["velocity_x"]
	velocity.y = state["velocity_y"]
	sync_to_physics_engine()
