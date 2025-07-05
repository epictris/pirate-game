extends SGCharacterBody2D

const SPEED = FI.ONE * 40

@export var explosion_scene: PackedScene
@onready var collision_shape: SGCollisionShape2D = %CollisionShape

func _ready() -> void:
	collision_layer = CollisionLayer.PROJECTILES
	collision_mask = CollisionLayer.PLAYERS | CollisionLayer.ITEMS | CollisionLayer.ENVIRONMENT | CollisionLayer.PROJECTILES

func _network_spawn(data: Dictionary) -> void:
	velocity = data.direction.mul(SPEED)
	fixed_position = data.fixed_position.copy()
	collision_shape.disabled = true # disable collision shape initially to prevent collision with player
	sync_to_physics_engine()

func _cast_ray(exceptions: Array) -> SGRayCastCollision2D:
	return SGPhysics2DServer.world_cast_ray(
		SGPhysics2DServer.get_default_world(), 
		fixed_position,
		velocity, 
		collision_mask,
		exceptions
	)

func _check_if_inside_collider(ray_cast_result: SGRayCastCollision2D) -> SGCollisionObject2D:
	return ray_cast_result.collider if ray_cast_result.normal.dot(velocity.normalized()) > 0 else null

func _resolve_collision(collider: SGPhysicsBody2D, point: SGFixedVector2) -> void:
	if collider.has_meta("resolve_collision"):
		collider.get_meta("resolve_collision").call({"collider": self})
	elif collider.has_method("get_hit"):
		collider.get_hit(self)
	_explode(point)

func _resolve_ray_collision() -> bool:
	var ray_cast_result = _cast_ray([self])
	if !ray_cast_result:
		return false
	var inside_collider = _check_if_inside_collider(ray_cast_result)
	if !inside_collider:
		fixed_position = fixed_position.add(velocity)
		sync_to_physics_engine()
		_resolve_collision(ray_cast_result.collider, ray_cast_result.point)
		return true

	# if we're inside a collision body, escape by excepting the body from collision then re-casting the ray
	var recast_result = _cast_ray([self, inside_collider])
	if recast_result:
		fixed_position = recast_result.point.copy()
		sync_to_physics_engine()
		_resolve_collision(recast_result.collider, recast_result.point)
	else:
		fixed_position = fixed_position.add(velocity)
		sync_to_physics_engine()
	return true

func _update() -> void:
	if _resolve_ray_collision():
		return
	collision_shape.disabled = false # enable collision shape the first time a ray cast yields no result
	var collision_result = move_and_collide(velocity)
	if collision_result:
		_resolve_collision(collision_result.collider, fixed_position.add(collision_result.remainder))

func _explode(target_position: SGFixedVector2) -> void:
	SyncManager.spawn("explosion", get_parent(), explosion_scene, {"fixed_position": target_position.copy()})
	SyncManager.despawn(self)
	

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

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	position.x = lerp(SGFixed.to_float(old_state.fixed_position_x), SGFixed.to_float(new_state.fixed_position_x), weight)
	position.y = lerp(SGFixed.to_float(old_state.fixed_position_y), SGFixed.to_float(new_state.fixed_position_y), weight)
