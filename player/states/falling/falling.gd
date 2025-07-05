extends Node

@export var falling_animation_scene: PackedScene

var falling_animation: Node2D

func _ready() -> void:
	SyncManager.scene_spawned.connect(_on_scene_spawned)

func enter(input: Dictionary, player: Player) -> void:
	SyncManager.spawn("falling_animation", player, falling_animation_scene, {"flip_h": _is_facing_left(input, player)})

func exit(_player: Player) -> void:
	SyncManager.despawn(falling_animation)

func _on_scene_spawned(scene_name: StringName, scene_node: Node, _data, _other) -> void:
	if scene_name == "falling_animation":
		falling_animation = scene_node

func _is_facing_left(input: Dictionary, player: Player) -> bool:
	return input.get("left") or player.velocity.x < 0
	

func preprocess_state_transition(_input, _player) -> PlayerState.MovementState:
	return PlayerState.MovementState.FALLING

func process_state(input: Dictionary, player: Player):
	player.apply_gravity()
	player._apply_air_acceleration(input)
	player.move_and_slide()

func postprocess_state_transition(_input: Dictionary, player: Player) -> PlayerState.MovementState:
	if player.is_on_floor():
		if player.velocity.x == 0:
			return PlayerState.MovementState.IDLE
		else:
			return PlayerState.MovementState.RUNNING
	elif player.is_on_wall():
		# IMPROVE: should not be setting values in this function
		player._touching_wall_normal = player.get_last_slide_collision().normal.x
		return PlayerState.MovementState.WALL_SLIDING
	return PlayerState.MovementState.FALLING
