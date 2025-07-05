class_name PlayerState extends Node

enum MovementState {
	IDLE,
	RUNNING,	
	JUMPING,
	FALLING,
	WALL_JUMPING,
	WALL_SLIDING,
	SLIDING,
}

@export var idle: Node
@export var running: Node
@export var falling: Node
@export var jumping: Node
@export var wall_jumping: Node
@export var wall_sliding: Node
@export var sliding: Node

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
		MovementState.SLIDING:
			return sliding
		_:
			assert(false, "Invalid state")
			return null

func _ready() -> void:
	current_state_node = idle
	SyncManager.sync_started.connect(_on_sync_manager_started)

func _on_sync_manager_started() -> void:
	current_state_node.enter({}, get_parent())

func process_tick(input: Dictionary):
	var player: Player = get_parent()

	var new_state = _resolve_state(current_state_node.preprocess_state_transition(input, player))
	if new_state != current_state_node:
		if current_state_node.has_method("exit"):
			current_state_node.exit(player)
		if new_state.has_method("enter"):
			new_state.enter(input, player)

	new_state.process_state(input, player)

	current_state_node = _resolve_state(new_state.postprocess_state_transition(input, player))
	if current_state_node != new_state:
		if new_state.has_method("exit"):
			new_state.exit(player)
		if current_state_node.has_method("enter"):
			current_state_node.enter(input, player)

	player._is_on_ceiling = player.is_on_ceiling()
	player._is_on_floor = player.is_on_floor()
	player._is_on_wall = player.is_on_wall()
