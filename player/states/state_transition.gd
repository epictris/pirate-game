class_name StateTransition extends Resource

var to: PlayerState.State
var from: PlayerState.State
var data: Dictionary

func _init(from_state: PlayerState.State, to_state: PlayerState.State, transition_data: Dictionary):
	self.from = from_state
	self.to = to_state
	self.data = transition_data
