extends AbilityBase

@export var pan_scene: PackedScene

func _ready() -> void:
	super()
	SyncManager.scene_spawned.connect(_on_scene_spawned)

func _preprocess_on_activated(direction: SGFixedVector2) -> void:
	if player.has_active_ability():
		return

	player.activate_ability(self)
	SyncManager.spawn(
		"pan", 
		player,
		pan_scene, 
		{
			"direction": direction
		}
	)

func _on_scene_spawned(node_name, spawned_node, _scene, _data):
	if node_name == "pan":
		spawned_node.finished.connect(_on_pan_finished)

func _on_pan_finished():
	player.deactivate_ability(self)
