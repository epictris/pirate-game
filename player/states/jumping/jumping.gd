extends PlayerState

@export var jump_animation_scene: PackedScene

var jump_animation: Node2D

func _ready() -> void:
	state_name = State.JUMPING
	SyncManager.scene_spawned.connect(_on_scene_spawned)
	super()

func _on_scene_spawned(scene_name: StringName, scene_node: Node, _data, _other) -> void:
	if scene_name == "jump_animation":
		jump_animation = scene_node

func _is_facing_left(input: Dictionary) -> bool:
	return input.get("left") or player.velocity.x < 0

func enter(input: Dictionary, _from_state: State, _data: Dictionary = {}) -> void:
	var is_facing_left: bool = _is_facing_left(input)
	SyncManager.spawn("jump_animation", player, jump_animation_scene, {"flip_h": is_facing_left})
	player.velocity.y -= player.jump_velocity
	if input.get("left"):
		player.velocity.x -= SGFixed.div(player.MAX_SPEED, SGFixed.ONE * 10)
	elif input.get("right"):
		player.velocity.x += SGFixed.div(player.MAX_SPEED, SGFixed.ONE * 10)

func exit(_to_state: State, _data: Dictionary = {}) -> void:
	SyncManager.despawn(jump_animation)

func process(input: Dictionary):
	player.velocity.y -= player.jump_gravity
	player._apply_air_acceleration(input)
	player.move_and_slide()

func get_postprocess_transition(_input: Dictionary) -> StateTransition:
	if player.velocity.y > 0:
		return self._transition_to(State.FALLING)
	if player.is_on_wall():
		# IMPROVE: should not be setting values in this function
		player._touching_wall_normal = player.get_last_slide_collision().normal.x
		return self._transition_to(State.WALL_SLIDING, {"wall_normal": player.get_last_slide_collision().normal.x})
	return null
