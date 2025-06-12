extends Control

func _ready():
	InteractionManager.interaction_available.connect(_on_interaction_available)
	InteractionManager.interaction_unavailable.connect(_on_interaction_unavailable)

func _on_interaction_available(prompt_text, callback):
	%PromptLabel.text = prompt_text
	show()

func _on_interaction_unavailable():
	hide()

func _input(event):
	if event.is_action_pressed("interact"):
		InteractionManager.trigger_interaction()
