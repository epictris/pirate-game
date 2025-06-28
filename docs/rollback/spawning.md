# Spawning

To spawning/despawn nodes in a rollback-compatible way, you need to use the `SpawnManager.spawn` and `SpawnManager.despawn` functions

Any setup required on the node itself should be done in the `_network_spawn` function on the spawned node. This function is called whenever the node is spawned or respawned. eg:

```gdscript
func _network_spawn(data: Dictionary) -> void:
	fixed_position_x = data["fixed_position_x"]
	fixed_position_y = data["fixed_position_y"]
```

Any storing of references to the node, or extra configuration that needs to be run on the parent whenever the node is spawned should be done in a function connected to the `SyncManager.scene_spawned` signal. eg:

```gdscript
@export var shield: PackedScene
var shield_instance: Node

func _ready() -> void:
	SyncManager.scene_spawned.connect(_on_scene_spawned)

func activate(direction: SGFixedVector2) -> void:
	SyncManager.spawn("shield", owner, shield, {}) # don't set the node reference here

func _on_scene_spawned(name, spawned_node, scene, data) -> void:
	if name == "shield":
		shield_instance = spawned_node # set the node reference here instead
```
