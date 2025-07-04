extends SGCharacterBody2D

@onready var timer: NetworkTimer = %NetworkTimer

signal finished()

var _direction: SGFixedVector2

func _ready():
	collision_mask = CollisionLayer.PLAYERS
	timer.timeout.connect(_on_timeout)

func _network_spawn(data: Dictionary) -> void:
	_direction = data["direction"]
	fixed_rotation = _direction.angle()
	timer.start()

func _save_state() -> Dictionary:
	return {
		fixed_rotation = fixed_rotation,
	}

func _load_state(state: Dictionary) -> void:
	fixed_rotation = state["fixed_rotation"]
	sync_to_physics_engine()

func _on_timeout() -> void:
	SyncManager.despawn(self)
	finished.emit()

# func resolve_collision(body: SGPhysicsBody2D) -> void:
# 	if body.is_in_group("projectile"):
# 		body.velocity = _direction.mul(body.velocity.length()).mul(FI.ONE_POINT_ONE)
