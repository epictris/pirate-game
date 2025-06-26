extends SGCharacterBody2D

const SPEED = 65536 * 20 * 2
const DISABLED_TICKS = 1

@onready var collision_shape: SGCollisionShape2D = %Collider
@onready var disable_timer: NetworkTimer = %DisableTimer

var enabled_tick: int
var remaining_bounces: int = 3

func _network_spawn(data: Dictionary) -> void:
	fixed_position_x = data["fixed_position_x"]
	fixed_position_y = data["fixed_position_y"]
	fixed_rotation = data["fixed_rotation"]
	var direction: SGFixedVector2 = SGFixed.vector2(SGFixed.ONE, 0).rotated(fixed_rotation)
	velocity = direction.mul(-SPEED)
	sync_to_physics_engine()
	disable_timer.timeout.connect(enable)

func enable() -> void:
	collision_shape.disabled = false
	sync_to_physics_engine()

func _network_process(input: Dictionary) -> void:
	var collision = move_and_collide(velocity)
	if collision:
		if collision.collider.has_method("take_damage"):
			collision.collider.take_damage()
			SyncManager.despawn(self)
			return
		if remaining_bounces == 0:
			SyncManager.despawn(self)
			return
		if collision.normal.x:
			velocity.x = -velocity.x
		if collision.normal.y:
			velocity.y = -velocity.y
		remaining_bounces -= 1

func _save_state() -> Dictionary:
	var state: Dictionary = {
		fixed_position_x = fixed_position_x,
		fixed_position_y = fixed_position_y,
		velocity_x = velocity.x,
		velocity_y = velocity.y,
		disabled = collision_shape.disabled,
		remaining_bounces = remaining_bounces
	}
	return state

func _load_state(state: Dictionary) -> void:
	fixed_position_x = state["fixed_position_x"]
	fixed_position_y = state["fixed_position_y"]
	velocity.x = state["velocity_x"]
	velocity.y = state["velocity_y"]
	collision_shape.disabled = state["disabled"]
	remaining_bounces = state["remaining_bounces"]

	sync_to_physics_engine()
