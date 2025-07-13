extends AbilityBase

@export var sabre_scene: PackedScene
var sabre_instance: SGArea2D

func _ready() -> void:
	super()
	SyncManager.scene_spawned.connect(_on_scene_spawned)

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

func _hook_after_player_movement() -> void:
	sabre_instance.update()

func _on_scene_spawned(node_name, spawned_node, _scene, data):
	if node_name == "sabre" and data.get("creator") == get_path():
		sabre_instance = spawned_node
		sabre_instance.finished.connect(_on_ability_finished)

func _on_ability_finished() -> void:
	SyncManager.despawn(sabre_instance)
	ability_manager.deactivate_ability(self)
