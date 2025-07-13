# Spawning

To spawning/despawn nodes in a rollback-compatible way, you need to use the `SpawnManager.spawn` and `SpawnManager.despawn` functions

Any setup required on the node itself should be done in the `_network_spawn` function on the spawned node. This function is called whenever the node is spawned or respawned. eg:

```gdscript
func _network_spawn(data: Dictionary) -> void:
	fixed_position_x = data["fixed_position_x"]
	fixed_position_y = data["fixed_position_y"]
```

If you need to:
- store a reference to the spawned node
- perform additional configuration on the parent whenever the node is spawned

This should be implemented in a function connected to the `SyncManager.scene_spawned` signal.

This function will be run whenever ANY scene is spawned/respawned - not just scenes spawned by this script instance. To ensure that the function isn't run on all instances of a class, include the node path of the node that called the spawn function in the spawn data. eg:

```gdscript
@export var shield: PackedScene
var shield_instance: Node

func _ready() -> void:
	SyncManager.scene_spawned.connect(_on_scene_spawned)

func activate(direction: SGFixedVector2) -> void:
	SyncManager.spawn(
		"shield",
		owner,
		shield,
		{ 
			creator = get_path() # add node path of creator to spawn data
		}
	) # don't set the node reference here

func _on_scene_spawned(name, spawned_node, scene, data) -> void:
	if name == "shield" and data.get("creator") == get_path(): # check spawner path to ensure code is only run on this instance
		shield_instance = spawned_node # set the node reference here instead
```

