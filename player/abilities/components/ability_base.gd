class_name AbilityBase extends Node

var player: Player

func _ready() -> void:
	player = owner

func update(_direction: SGFixedVector2) -> void:
	pass

func activate(_direction: SGFixedVector2) -> void:
	pass

func deactivate(_direction: SGFixedVector2) -> void:
	pass
