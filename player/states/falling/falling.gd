extends PlayerState

@export var falling_animation_scene: PackedScene

var falling_animation: Node2D

func _ready() -> void:
	state_name = State.FALLING
	SyncManager.scene_spawned.connect(_on_scene_spawned)
	super()

func enter(input: Dictionary, _from_state: State, _data: Dictionary = {}) -> void:
	SyncManager.spawn("falling_animation", player, falling_animation_scene, {"flip_h": _is_facing_left(input)})

func exit(_to_state: State, _data: Dictionary = {}) -> void:
	SyncManager.despawn(falling_animation)

func _on_scene_spawned(scene_name: StringName, scene_node: Node, _data, _other) -> void:
	if scene_name == "falling_animation":
		falling_animation = scene_node

func _is_facing_left(input: Dictionary) -> bool:
	return input.get("left") or player.velocity.x < 0
	
func process(input: Dictionary) -> void:
	player.apply_gravity()
	player._apply_air_acceleration(input)
	player.move_and_slide()

func get_postprocess_transition(_input: Dictionary) -> StateTransition:
	if player.is_on_floor():
		if player.velocity.x == 0:
			return self._transition_to(State.IDLE)
		else:
			return self._transition_to(State.RUNNING)
	elif player.is_on_wall():
		# IMPROVE: should not be setting values in this function
		player._touching_wall_normal = player.get_last_slide_collision().normal.x
		return self._transition_to(State.WALL_SLIDING)
	return null
