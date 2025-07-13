extends AbilityBase

@export var pan_scene: PackedScene

var pan_instance: SGCharacterBody2D

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
			"direction": direction,
			"parent": player.get_path()
		}
	)


func _hook_after_player_movement() -> void:
	pan_instance.sync_to_physics_engine() # pan fixed position does not automatically sync when player moves


func _on_scene_spawned(node_name, spawned_node, _scene, _data):
	if node_name == "pan" and _data.get("parent") == player.get_path():
		pan_instance = spawned_node
		spawned_node.finished.connect(_on_pan_finished)
		

func _on_pan_finished():
	pan_instance = null
	player.deactivate_ability(self)
