extends PlayerState
@export var idle_animation_scene: PackedScene

var idle_animation: Node2D

func _ready() -> void:
	state_name = State.IDLE
	SyncManager.scene_spawned.connect(_on_scene_spawned)
	super()

func _on_scene_spawned(scene_name: StringName, scene_node: Node, _data, _other) -> void:
	if scene_name == "idle_animation":
		idle_animation = scene_node

func enter(_input: Dictionary, _from_state: State, _data: Dictionary = {}) -> void:
	SyncManager.spawn("idle_animation", player, idle_animation_scene)

func exit(_to_state: State, _data: Dictionary = {}) -> void:
	SyncManager.despawn(idle_animation)

func get_preprocess_transition(input: Dictionary) -> StateTransition:
	if input.get("up"):
		return self._transition_to(State.JUMPING)
	if input.get("left") or input.get("right"):
		return self._transition_to(State.RUNNING)
	return null

func process(_input: Dictionary):
	player.apply_gravity()
	player.move_and_slide()

func get_postprocess_transition(_input: Dictionary) -> StateTransition:
	if !player.is_on_floor():
		return self._transition_to(State.FALLING)
	return null
