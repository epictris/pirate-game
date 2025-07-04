extends AbilityBase

@export var pan_scene: PackedScene

var pan_instance: SGCharacterBody2D

func _ready() -> void:
	super()
	SyncManager.scene_spawned.connect(_on_scene_spawned)
	SyncManager.scene_despawned.connect(_on_scene_despawned)

func activate(direction: SGFixedVector2) -> void:
	if !is_active():
		SyncManager.spawn(
			"pan", 
			player,
			pan_scene, 
			{
				"direction": direction
			}
		)

func _on_scene_spawned(node_name, spawned_node, _scene, _data) -> void:
	if node_name == "pan":
		pan_instance = spawned_node
		set_active(true)

func _on_scene_despawned(node_name, _despawned_node) -> void:
	if node_name == "pan":
		pan_instance = null
		set_active(false)
