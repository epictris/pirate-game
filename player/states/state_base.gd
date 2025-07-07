class_name PlayerState extends Node

enum State {
	IDLE,
	RUNNING,
	FALLING,
	JUMPING,
	WALL_JUMPING,
	WALL_SLIDING,
	SLIDING,
}

var player: Player
var state_name: State

func _ready() -> void:
	player = owner
	get_parent().register_state(self)

func _transition_to(new_state: State, data: Dictionary = {}) -> StateTransition:
	return StateTransition.new(state_name, new_state, data)

func enter(_input: Dictionary, _from_state: State, _data: Dictionary = {}) -> void:
	return

func get_preprocess_transition(_input: Dictionary) -> StateTransition:
	return null

func process(_input: Dictionary) -> void:
	return

func get_postprocess_transition(_input: Dictionary) -> StateTransition:
	return null

func exit(to_state: State, _data: Dictionary = {}) -> void:
	return


