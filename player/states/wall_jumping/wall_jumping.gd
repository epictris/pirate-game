extends Node

@export var wall_jump_animation_scene: PackedScene

var wall_jump_animation: Node2D

func _ready() -> void:
	SyncManager.scene_spawned.connect(_on_scene_spawned)

func _on_scene_spawned(scene_name: StringName, scene_node: Node, _data, _other) -> void:
	if scene_name == "wall_jump_animation":
		wall_jump_animation = scene_node

func _is_facing_left(input: Dictionary, player: Player) -> bool:
	return input.get("left") or player.velocity.x < 0

func exit(_player: Player) -> void:
	SyncManager.despawn(wall_jump_animation)

func enter(_input: Dictionary, player: Player) -> void:
	SyncManager.spawn("wall_jump_animation", player, wall_jump_animation_scene, {"flip_h": player._touching_wall_normal > 0})
	player.velocity.y = -player.jump_velocity
	player.velocity.x = SGFixed.mul(player._touching_wall_normal, player.jump_velocity)

func preprocess_state_transition(_input: Dictionary, _player: Player) -> PlayerState.MovementState:
	return PlayerState.MovementState.WALL_JUMPING

func process_state(input: Dictionary, player: Player):
	player.velocity.y -= player.jump_gravity
	player._apply_air_acceleration(input)
	player.move_and_slide()

func postprocess_state_transition(player: Player) -> PlayerState.MovementState:
	if player.velocity.y > 0:
		return PlayerState.MovementState.FALLING
	if player.is_on_wall():
		# IMPROVE: should not be setting values in this function
		player._touching_wall_normal = player.get_last_slide_collision().normal.x
		return PlayerState.MovementState.WALL_SLIDING
	return PlayerState.MovementState.WALL_JUMPING
