extends Node

@export var run_animation_scene: PackedScene

var run_animation: Node2D
var was_facing_left: bool

func _ready() -> void:
	SyncManager.scene_spawned.connect(_on_scene_spawned)

func _on_scene_spawned(scene_name: StringName, scene_node: Node, _data, _other) -> void:
	if scene_name == "run_animation":
		run_animation = scene_node
func _is_facing_left(input: Dictionary, player: Player) -> bool:
	return input.get("left") or player.velocity.x < 0

func enter(input: Dictionary, player: Player) -> void:
	was_facing_left = _is_facing_left(input, player)
	SyncManager.spawn("run_animation", player, run_animation_scene, {"flip_h": was_facing_left})

func exit(_player: Player) -> void:
	SyncManager.despawn(run_animation)

func preprocess_state_transition(input, _player) -> PlayerState.MovementState:
	if input.get("up"):
		return PlayerState.MovementState.JUMPING
	return PlayerState.MovementState.RUNNING

func process_state(input: Dictionary, player: Player):
	var right_motion: int = SGFixed.ONE if input.get("right") else 0
	var left_motion: int = SGFixed.NEG_ONE if input.get("left") else 0

	player.apply_gravity()

	if !right_motion and !left_motion:
		player._apply_ground_friction()

	player.velocity.x += SGFixed.mul(right_motion + left_motion, player.GROUND_ACCEL)
	player.velocity.x = clamp(player.velocity.x, -player.current_max_speed, player.current_max_speed)

	var is_facing_left: bool = _is_facing_left(input, player)
	if is_facing_left != was_facing_left:
		SyncManager.despawn(run_animation)
		SyncManager.spawn("run_animation", player, run_animation_scene, {"flip_h": is_facing_left})
		was_facing_left = is_facing_left

	player.move_and_slide()


func postprocess_state_transition(player: Player) -> PlayerState.MovementState:
	if !player.is_on_floor():
		return PlayerState.MovementState.FALLING
	elif player.velocity.x == 0:
		return PlayerState.MovementState.IDLE
	return PlayerState.MovementState.RUNNING
