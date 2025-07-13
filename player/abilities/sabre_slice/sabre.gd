extends SGArea2D

signal finished

@onready var frames = get_children().filter(func(node): return node is SGCollisionPolygon2D)

var start_tick: int

func _network_spawn(data: Dictionary) -> void:
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
		return

	update_active_frames()

	for body in get_overlapping_bodies():
		if body == get_parent():
			continue
		if body.has_method("take_damage"):
			body.take_damage()
		if body.is_in_group("projectile"):
			SyncManager.despawn(body)
			

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
