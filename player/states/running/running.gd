extends PlayerState

@export var run_animation_scene: PackedScene

var run_animation: Node2D
var was_facing_left: bool

func _ready() -> void:
	state_name = State.RUNNING
	SyncManager.scene_spawned.connect(_on_scene_spawned)
	super()

func _on_scene_spawned(scene_name: StringName, scene_node: Node, _data, _other) -> void:
	if scene_name == "run_animation":
		run_animation = scene_node

func _is_facing_left(input: Dictionary) -> bool:
	return input.get("left") or player.velocity.x < 0

func enter(input: Dictionary, _from_state: State, _data: Dictionary = {}) -> void:
	was_facing_left = _is_facing_left(input)
	SyncManager.spawn("run_animation", player, run_animation_scene, {"flip_h": was_facing_left})

func exit(_to_state: State, _data: Dictionary = {}) -> void:
	SyncManager.despawn(run_animation)

func get_preprocess_transition(input: Dictionary) -> StateTransition:
	if input.get("up"):
		return self._transition_to(State.JUMPING)
	if input.get("down"):
		return self._transition_to(State.SLIDING)
	return null

func process(input: Dictionary):
	var right_motion: int = SGFixed.ONE if input.get("right") else 0
	var left_motion: int = SGFixed.NEG_ONE if input.get("left") else 0

	player.apply_gravity()

	if !right_motion and !left_motion:
		player._apply_ground_friction()

	player.velocity.x += SGFixed.mul(right_motion + left_motion, player.GROUND_ACCEL)
	player.velocity.x = clamp(player.velocity.x, -player.current_max_speed, player.current_max_speed)

	var is_facing_left: bool = _is_facing_left(input)
	if is_facing_left != was_facing_left:
		SyncManager.despawn(run_animation)
		SyncManager.spawn("run_animation", player, run_animation_scene, {"flip_h": is_facing_left})
		was_facing_left = is_facing_left

	player.move_and_slide()


func get_postprocess_transition(_input: Dictionary) -> StateTransition:
	if !player.is_on_floor():
		return self._transition_to(State.FALLING)
	elif player.velocity.x == 0:
		return self._transition_to(State.IDLE)
	return null
