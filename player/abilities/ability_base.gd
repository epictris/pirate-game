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


func _on_input_activated(_direction: SGFixedVector2) -> void:
	pass

func _on_input_updated(_direction: SGFixedVector2) -> void:
	pass

func _on_input_deactivated(_direction: SGFixedVector2) -> void:
	pass

func _hook_before_player_movement() -> void:
	pass

func _should_override_movement() -> bool:
	return false

func _hook_after_player_movement() -> void:
	pass
