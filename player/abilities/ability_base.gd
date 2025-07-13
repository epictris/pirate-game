class_name AbilityBase extends Node

var player: Player
var ability_manager: AbilityManager

func _ready() -> void:
	player = owner
	ability_manager = get_parent()

func _preprocess_on_activated(_direction: SGFixedVector2) -> void:
	pass

func _preprocess_on_updated(_direction: SGFixedVector2) -> void:
	pass

func _preprocess_on_deactivated(_direction: SGFixedVector2) -> void:
	pass

func _hook_before_player_movement() -> void:
	pass

func _should_override_movement() -> bool:
	return false

func _hook_after_player_movement() -> void:
	pass

func _postprocess_on_activated(_direction: SGFixedVector2) -> void:
	pass

func _postprocess_on_updated(_direction: SGFixedVector2) -> void:
	pass

func _postprocess_on_deactivated(_direction: SGFixedVector2) -> void:
	pass
