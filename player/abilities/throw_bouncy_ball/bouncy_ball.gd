extends Node2D

const SPEED = 65536 * 20 * 2
const DISABLED_TICKS = 1

@onready var disable_timer: NetworkTimer = %DisableTimer

var enabled_tick: int
var remaining_bounces: int = 3

var fixed_position: SGFixedVector2 = SGFixed.vector2(0, 0)
var velocity: SGFixedVector2 = SGFixed.vector2(0, 0)

func _ready():
	position = fixed_position.to_float()

func _network_spawn(data: Dictionary) -> void:
	fixed_position.x = data["fixed_position"].x
	fixed_position.y = data["fixed_position"].y
	var direction: SGFixedVector2 = SGFixed.vector2(data["direction"].x, data["direction"].y)
	fixed_position = fixed_position.add(direction.mul(FI.ONE * 30))
	velocity = direction.mul(SPEED)
	position = fixed_position.to_float()

func _update() -> void:
	# hacky fix for collision with objects moving towards the ball.
	# should probably check behind the ball to account for objects that phased through.
	# or maybe check two frames ahead of the ball.
	var cast_to = velocity.mul(FI.ONE_POINT_TWO)

	var result = SGPhysics2DServer.world_cast_ray(SGPhysics2DServer.get_default_world(), fixed_position, cast_to, 255, [], true)

	if result:
		fixed_position = result.point
		position = fixed_position.to_float()
		if result.collider.has_method("take_damage"):
			result.collider.take_damage()
			_despawn()
			return
		if result.collider.has_method("collide"):
			result.collider.collide(self)
		if remaining_bounces == 0:
			_despawn()
			return

		if result.collider.has_method("get_velocity"):
			fixed_position = fixed_position.add(result.collider.get_velocity())

		SGPhysics2DServer.get_default_world()

		rebound(result.normal)
		remaining_bounces -= 1

	else:
		fixed_position = fixed_position.add(velocity)
	position = fixed_position.to_float()

func _despawn() -> void:
	SyncManager.despawn(self)


func _save_state() -> Dictionary:
	var state: Dictionary = {
		fixed_position_x = fixed_position.x,
		fixed_position_y = fixed_position.y,
		velocity_x = velocity.x,
		velocity_y = velocity.y,
		remaining_bounces = remaining_bounces
	}
	return state

func _load_state(state: Dictionary) -> void:
	fixed_position.x = state["fixed_position_x"]
	fixed_position.y = state["fixed_position_y"]
	velocity.x = state["velocity_x"]
	velocity.y = state["velocity_y"]
	remaining_bounces = state["remaining_bounces"]
	position = fixed_position.to_float()

func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	position.x = lerp(SGFixed.to_float(old_state.fixed_position_x), SGFixed.to_float(new_state.fixed_position_x), weight)
	position.y = lerp(SGFixed.to_float(old_state.fixed_position_y), SGFixed.to_float(new_state.fixed_position_y), weight)

func rebound(collision_normal: SGFixedVector2) -> void:
	var rebound_angle = collision_normal.angle_to(velocity.normalized()) * 2
	velocity = velocity.mul(-FI.ONE).rotated(-rebound_angle)
