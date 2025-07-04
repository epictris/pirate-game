class_name PlayerState extends Node

enum MovementState {
	IDLE,
	RUNNING,	
	JUMPING,
	FALLING,
	WALL_JUMPING,
	WALL_SLIDING,
}

@export var idle: Node
@export var running: Node
@export var falling: Node
@export var jumping: Node
@export var wall_jumping: Node
@export var wall_sliding: Node

var current_state: MovementState = MovementState.IDLE
var current_state_node: Node

func _resolve_state(state: MovementState) -> Node:
	match state:
		MovementState.IDLE:
			return idle
		MovementState.RUNNING:
			return running
		MovementState.FALLING:
			return falling
		MovementState.JUMPING:
			return jumping
		MovementState.WALL_JUMPING:
			return wall_jumping
		MovementState.WALL_SLIDING:
			return wall_sliding
		_:
			assert(false, "Invalid state")
			return null

func _ready() -> void:
	current_state_node = idle

func process_tick(input: Dictionary):
	var player: Player = get_parent()

	var new_state = _resolve_state(current_state_node.preprocess_state_transition(input, player))
	if new_state != current_state_node and new_state.has_method("enter"):
		new_state.enter(player)

	new_state.process_state(input, player)

	current_state_node = _resolve_state(new_state.postprocess_state_transition(player))

	# IMPROVE: call state enter() method if state has changed - probably need to call it at the start of the next frame

	player._is_on_ceiling = player.is_on_ceiling()
	player._is_on_floor = player.is_on_floor()
	player._is_on_wall = player.is_on_wall()
