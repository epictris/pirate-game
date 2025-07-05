extends Node

@export var idle_animation_scene: PackedScene

var idle_animation: Node2D

func _ready() -> void:
	SyncManager.scene_spawned.connect(_on_scene_spawned)

func _on_scene_spawned(scene_name: StringName, scene_node: Node, _data, _other) -> void:
	if scene_name == "idle_animation":
		idle_animation = scene_node

func enter(_input: Dictionary, player: Player) -> void:
	SyncManager.spawn("idle_animation", player, idle_animation_scene)

func exit(_player: Player) -> void:
	SyncManager.despawn(idle_animation)

func preprocess_state_transition(input, _player) -> PlayerState.MovementState:
	if input.get("up"):
		return PlayerState.MovementState.JUMPING
	if input.get("left") or input.get("right"):
		return PlayerState.MovementState.RUNNING
	return PlayerState.MovementState.IDLE

func process_state(_input: Dictionary, player: Player):
	player.apply_gravity()
	player.move_and_slide()

func postprocess_state_transition(_input: Dictionary, player: Player) -> PlayerState.MovementState:
	if !player.is_on_floor():
		return PlayerState.MovementState.FALLING
	return PlayerState.MovementState.IDLE
