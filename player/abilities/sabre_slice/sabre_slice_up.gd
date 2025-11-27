extends SGArea2D

signal finished

@onready var frames = get_children().filter(func(node): return node is SGCollisionPolygon2D)
@onready var rng: NetworkRandomNumberGenerator = %NetworkRandomNumberGenerator

var start_tick: int

func _ready() -> void:
	set_meta("resolve_collision", _resolve_collision)

func _network_spawn(data: Dictionary) -> void:
	rng.set_seed(data.rng_seed)
	start_tick = data.start_tick
	var direction: SGFixedVector2 = data.direction
	if direction.x < 0:
		fixed_scale.x = -FI.ONE
	for frame in frames:
		frame.disabled = true
		frame.visible = false

func update() -> void:
	var animation_frame = SyncManager.current_tick - start_tick
	if animation_frame >= frames.size():
		finished.emit()
		SyncManager.despawn(self)
		return

	update_active_frames()

	for body in get_overlapping_bodies():
		if body == get_parent():
			continue
		if body.has_method("take_damage"):
			body.take_damage()
		if body.is_in_group("projectile"):
			_resolve_collision({collider = body, point = body.fixed_position})

func update_active_frames() -> void:
	for frame in frames:
		frame.disabled = true
		frame.visible = false
	frames[SyncManager.current_tick - start_tick].disabled = false
	frames[SyncManager.current_tick - start_tick].visible = true
	sync_to_physics_engine()


func _save_state() -> Dictionary:
	return {
		"start_tick": start_tick,
	}

func _load_state(state: Dictionary) -> void:
	start_tick = state.start_tick

func _resolve_collision(data: Dictionary) -> void:
	data.collider.fixed_position = data.point.copy()
	data.collider.velocity = SGFixed.vector2(0, -FI.ONE).rotated(SGFixed.mul(-rng.randi() % FI.ONE_POINT_FIVE, -fixed_scale_x)).mul(data.collider.velocity.length())
	data.collider.sync_to_physics_engine()
