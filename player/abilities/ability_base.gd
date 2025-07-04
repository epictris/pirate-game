class_name AbilityBase extends Node

var _active: bool = false

var player: Player

func _ready() -> void:
	player = owner

func modify(_direction: SGFixedVector2) -> void:
	pass

func activate(_direction: SGFixedVector2) -> void:
	pass

func deactivate(_direction: SGFixedVector2) -> void:
	pass

func is_active() -> bool:
	return _active

func set_active(active: bool) -> void:
	_active = active
