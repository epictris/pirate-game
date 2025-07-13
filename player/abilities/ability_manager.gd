class_name AbilityManager extends Node

@export var primary: AbilityBase
@export var secondary: AbilityBase
@export var special: AbilityBase

var _current_ability: AbilityBase

func activate_ability(ability: AbilityBase, allow_overwrite: bool = false) -> void:
	assert(allow_overwrite or !_current_ability, "Attempting to activate an ability while an ability is already active")
	_current_ability = ability

func deactivate_ability(ability: AbilityBase) -> void:
	assert(_current_ability == ability, "Attempting to deactivate ability that is not currently active")
	_current_ability = null

func has_active_ability() -> bool:
	return true if _current_ability else false

func is_ability_active(ability: AbilityBase) -> bool:
	return ability == _current_ability

func _preprocess_ability_input(input: Dictionary) -> void:
	if primary:
		if !_current_ability and input.get("primary_activated") and primary.has_method("_preprocess_on_activated"):
			primary._preprocess_on_activated(input["direction"])
		if !_current_ability and input.get("primary_updated") and primary.has_method("_preprocess_on_activated"):
			# Treat update as activation input if no ability is active
			primary._preprocess_on_activated(input["direction"])
		if _current_ability == primary:
			if input.get("primary_updated") and primary.has_method("_preprocess_on_updated"):
				primary._preprocess_on_updated(input["direction"])
			if input.get("primary_deactivated") and primary.has_method("_preprocess_on_deactivated"):
				primary._preprocess_on_deactivated(input["direction"])

	if secondary:
		if !_current_ability and input.get("secondary_activated") and secondary.has_method("_preprocess_on_activated"):
			secondary._preprocess_on_activated(input["direction"])
		if !_current_ability and input.get("secondary_updated") and secondary.has_method("_preprocess_on_activated"):
			# Treat update as activation input if no ability is active
			secondary._preprocess_on_activated(input["direction"])
		if _current_ability == secondary:
			if input.get("secondary_updated") and secondary.has_method("_preprocess_on_updated"):
				secondary._preprocess_on_updated(input["direction"])
			if input.get("secondary_deactivated") and secondary.has_method("_preprocess_on_deactivated"):
				secondary._preprocess_on_deactivated(input["direction"])

func _postprocess_ability_input(input: Dictionary) -> void:
	if primary:
		if (!_current_ability or _current_ability == primary) and input.get("primary_activated") and primary.has_method("_postprocess_on_activated"):
			primary._postprocess_on_activated(input["direction"])
		if !_current_ability and input.get("primary_updated") and primary.has_method("_postprocess_on_activated"):
			# Treat update as activation input if no ability is active
			primary._postprocess_on_activated(input["direction"])
		if _current_ability == primary:
			if input.get("primary_updated") and primary.has_method("_postprocess_on_updated"):
				primary._postprocess_on_updated(input["direction"])
			if input.get("primary_deactivated") and primary.has_method("_postprocess_on_deactivated"):
				primary._postprocess_on_deactivated(input["direction"])

	if secondary:
		if (!_current_ability or _current_ability == secondary) and input.get("secondary_activated") and secondary.has_method("_postprocess_on_activated"):
			secondary._postprocess_on_activated(input["direction"])
		if !_current_ability and input.get("secondary_updated") and secondary.has_method("_postprocess_on_activated"):
			# Treat update as activation input if no ability is active
			secondary._postprocess_on_activated(input["direction"])
		if _current_ability == secondary:
			if input.get("secondary_updated") and secondary.has_method("_postprocess_on_updated"):
				secondary._postprocess_on_updated(input["direction"])
			if input.get("secondary_deactivated") and secondary.has_method("_postprocess_on_deactivated"):
				secondary._postprocess_on_deactivated(input["direction"])

func preprocess_ability(input: Dictionary) -> void:
	_preprocess_ability_input(input)
	if _current_ability:
		_current_ability._hook_before_player_movement()

func should_override_movement() -> bool:
	if _current_ability:
		return _current_ability._should_override_movement()
	return false

func postprocess_ability(input: Dictionary) -> void:
	if _current_ability:
		_current_ability._hook_after_player_movement()
	_postprocess_ability_input(input)

func _save_state() -> Dictionary:
	var state: Dictionary = {}
	if _current_ability:
		state["current_ability"] = _current_ability.get_path()
	return state

func _load_state(state: Dictionary) -> void:
	_current_ability = get_node(state.get("current_ability")) if state.has("current_ability") else null
