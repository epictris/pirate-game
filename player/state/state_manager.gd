class_name PlayerStateMachine extends Node

@export var initial_state: PlayerState

signal state_transitioned(from: PlayerState.State, to: PlayerState.State)

var _states: Dictionary[PlayerState.State, PlayerState] = {}
var current_state_node: PlayerState

func register_state(state: PlayerState):
	_states[state.state_name] = state

func _ready() -> void:
	current_state_node = initial_state
	SyncManager.sync_started.connect(_on_sync_manager_started)

func _on_sync_manager_started() -> void:
	current_state_node.enter({}, current_state_node.state_name)

func get_state() -> PlayerState.State:
	return current_state_node.state_name

func process_tick(input: Dictionary):
	var preprocess_transition = current_state_node.get_preprocess_transition(input)
	if preprocess_transition:
		current_state_node.exit(preprocess_transition.to)
		current_state_node = _states[preprocess_transition.to]
		current_state_node.enter(input, preprocess_transition.from, preprocess_transition.data)
		state_transitioned.emit(preprocess_transition)

	current_state_node.process(input)

	var postprocess_transition = current_state_node.get_postprocess_transition(input)
	if postprocess_transition:
		current_state_node.exit(postprocess_transition.to)
		current_state_node = _states[postprocess_transition.to]
		current_state_node.enter(input, postprocess_transition.from, postprocess_transition.data)
		state_transitioned.emit(postprocess_transition)

	var player = get_parent()
	player._is_on_ceiling = player.is_on_ceiling()
	player._is_on_floor = player.is_on_floor()
	player._is_on_wall = player.is_on_wall()
