extends AbilityBase

@export var sabre_scene: PackedScene
var sabre_instance: SGArea2D

func _ready() -> void:
	super()
	SyncManager.scene_spawned.connect(_on_scene_spawned)

var is_stuck: bool = false

func _preprocess_on_activated(direction: SGFixedVector2) -> void:
	if ability_manager.is_ability_active(self):
		return

	ability_manager.activate_ability(self)
	SyncManager.spawn(
		"sabre",
		player,
		sabre_scene,
		{
			"direction": direction,
			"creator": get_path(),
			"start_tick": SyncManager.current_tick,
		}
	)

func _should_override_movement() -> bool:
	return is_stuck

func _hook_before_player_movement() -> void:
	sabre_instance.update()

func _on_scene_spawned(node_name, spawned_node, _scene, data):
	if node_name == "sabre" and data.get("creator") == get_path():
		sabre_instance = spawned_node
		sabre_instance.finished.connect(_on_ability_finished)
		sabre_instance.stuck.connect(_on_stuck)

func _on_ability_finished() -> void:
	SyncManager.despawn(sabre_instance)
	ability_manager.deactivate_ability(self)
	sabre_instance = null
	is_stuck = false

func _on_stuck() -> void:
	is_stuck = true
	player.velocity = SGFixed.vector2(0, 0)

func _save_state() -> Dictionary:
	return {
		"is_stuck": is_stuck,
	}

func _load_state(state: Dictionary) -> void:
	is_stuck = state.is_stuck

