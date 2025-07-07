extends PlayerState

@export var wall_slide_animation_scene: PackedScene

var wall_slide_animation: Node2D

func _ready() -> void:
	state_name = State.WALL_SLIDING
	SyncManager.scene_spawned.connect(_on_scene_spawned)
	super()

func _on_scene_spawned(scene_name: StringName, scene_node: Node, _data, _other) -> void:
	if scene_name == "wall_slide_animation":
		wall_slide_animation = scene_node

func enter(_input: Dictionary, _from_state: State, _data: Dictionary = {}) -> void:
	SyncManager.spawn("wall_slide_animation", player, wall_slide_animation_scene, {"flip_h": player._touching_wall_normal > 0})

func exit(_to_state: State, _data: Dictionary = {}) -> void:
	SyncManager.despawn(wall_slide_animation)


func get_preprocess_transition(input: Dictionary) -> StateTransition:
	if input.get("up_just_pressed"):
		return self._transition_to(State.WALL_JUMPING)
	if input.get("down"):
		return self._transition_to(State.SLIDING)
	if player.get_x_input(input) * player._touching_wall_normal > 0:
		return self._transition_to(State.FALLING)
	return null

func process(_input: Dictionary):
	if player.velocity.y < 0:
		player.velocity.y -= player.jump_gravity
	else:
		player.velocity.y -= player.WALL_FRICTION
		player.velocity.y = max(player.velocity.y, player.WALL_SLIDE_SPEED)

	player.velocity.x = -player._touching_wall_normal # small x velocity to ensure is_on_wall() resolves to true
	player.move_and_slide()

func get_postprocess_transition(_input: Dictionary) -> StateTransition:
	if player.is_on_floor():
		return self._transition_to(State.IDLE)
	elif !player.is_on_wall():
		# IMPROVE: should not be setting values in this function
		player.velocity.x = 0
		return self._transition_to(State.FALLING)
	return null
