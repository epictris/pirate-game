extends PlayerState

@export var slide_animation_scene: PackedScene

var slide_animation: Node2D

func _ready() -> void:
	state_name = State.SLIDING
	SyncManager.scene_spawned.connect(_on_scene_spawned)
	super()

func _on_scene_spawned(scene_name: StringName, scene_node: Node, _data, _other) -> void:
	if scene_name == "slide_animation":
		slide_animation = scene_node

func _is_facing_left(input: Dictionary) -> bool:
	return input.get("left") or player.velocity.x < 0

func enter(input: Dictionary, _from_state: State, _data: Dictionary = {}) -> void:
	SyncManager.spawn("slide_animation", player, slide_animation_scene, {"flip_h": _is_facing_left(input)})
	player.collision_shape.shape.extents.x = 65536 * 25
	player.collision_shape.shape.extents.y = 65536 * 10
	player.fixed_position.y = player.fixed_position.y + 65536 * 14
	player.sync_to_physics_engine()

func exit(_to_state: State, _data: Dictionary = {}) -> void:
	SyncManager.despawn(slide_animation)
	player.collision_shape.shape.extents.x = 65536 * 10
	player.collision_shape.shape.extents.y = 65536 * 25
	player.fixed_position.y = player.fixed_position.y - 65536 * 14
	player.sync_to_physics_engine()

func get_preprocess_transition(input: Dictionary) -> StateTransition:
	if !input.get("down") and (input.get("left") or input.get("right")):
		return self._transition_to(State.RUNNING)
	if input.get("up"):
		return self._transition_to(State.JUMPING)
	return null


func process(_input: Dictionary):
	player.apply_gravity()
	player.apply_slide_friction()
	player.move_and_slide()

func get_postprocess_transition(input: Dictionary) -> StateTransition:
	if !player.is_on_floor():
		return self._transition_to(State.FALLING)
	elif player.velocity.x == 0 and !input.get("down"):
		return self._transition_to(State.IDLE)
	return null
