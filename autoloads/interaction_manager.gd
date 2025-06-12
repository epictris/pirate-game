extends Node

signal interaction_available(prompt_text, callback)
signal interaction_unavailable()

var current_interaction = null

func register_interaction(prompt_text, callback):
	current_interaction = callback
	interaction_available.emit(prompt_text, callback)

func unregister_interaction():
	current_interaction = null
	interaction_unavailable.emit()

func trigger_interaction():
	if current_interaction:
		current_interaction.call()
