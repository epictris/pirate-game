extends Node

@export var slide_animation_scene: PackedScene

var slide_animation: Node2D

func _ready() -> void:
	SyncManager.scene_spawned.connect(_on_scene_spawned)

func _on_scene_spawned(scene_name: StringName, scene_node: Node, _data, _other) -> void:
	if scene_name == "slide_animation":
		slide_animation = scene_node

func _is_facing_left(input: Dictionary, player: Player) -> bool:
	return input.get("left") or player.velocity.x < 0

func enter(input: Dictionary, player: Player) -> void:
	SyncManager.spawn("slide_animation", player, slide_animation_scene, {"flip_h": _is_facing_left(input, player)})
	player.collision_shape.shape.extents.x = 65536 * 25
	player.collision_shape.shape.extents.y = 65536 * 10
	player.fixed_position.y = player.fixed_position.y + 65536 * 14
	player.sync_to_physics_engine()

func exit(player: Player) -> void:
	SyncManager.despawn(slide_animation)
	player.collision_shape.shape.extents.x = 65536 * 10
	player.collision_shape.shape.extents.y = 65536 * 25
	player.fixed_position.y = player.fixed_position.y - 65536 * 14
	player.sync_to_physics_engine()

func preprocess_state_transition(input, player) -> PlayerState.MovementState:
	if !input.get("down"):
		return PlayerState.MovementState.RUNNING if player.velocity.x != 0 else PlayerState.MovementState.IDLE
	return PlayerState.MovementState.SLIDING

func process_state(_input: Dictionary, player: Player):
	player.apply_gravity()
	player.apply_slide_friction()
	player.move_and_slide()

func postprocess_state_transition(input: Dictionary, player: Player) -> PlayerState.MovementState:
	if !player.is_on_floor():
		return PlayerState.MovementState.FALLING
	elif player.velocity.x == 0 and !input.get("down"):
		return PlayerState.MovementState.IDLE
	return PlayerState.MovementState.SLIDING
