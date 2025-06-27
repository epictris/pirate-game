# Errors

```
Invalid type in function 'despawn' in base 'Node (SyncManager.gd)'. The Object-derived class of argument 1 (previously freed) is not a subclass of the expected argument class.
```

This means you're trying to despawn a node that has already been despawned. This can happen when:
1. the scene is spawned (eg. on tick 10)
2. you store a reference to the spawned node in a variable on the parent.
2. you despawn the referenced node (eg. on tick 20)
3. a rollback occurs (eg. rollback to tick 15)
4. the scene is automatically respawned by the SyncManager, but the variable on the parent is not updated with the new node reference.
5. the rollback attempts to despawn the respawned scene using the variable on the parent (which references the already despawned node).

This is an example of some code that could trigger this error.

```gdscript
@export var shield: PackedScene
var shield_instance: Node

func activate(direction: SGFixedVector2) -> void:
	shield_instance = SyncManager.spawn("shield", owner, shield, {}) # storing node reference when scene is first created

func deactivate() -> void:
	SyncManager.despawn(shield_instance) # passing node reference to despawn
```

If the state is rolled back to a tick *after* the spawn code is run, but *before* the despawn code is run, none of the spawning code is re-run. Any code that should be re-run whenever the scene is spawned/respawned needs to be run in a function connected to the SyncManager.scene_spawned signal. eg.

```gdscript
@export var shield: PackedScene
var shield_instance: Node

func _ready() -> void:
	SyncManager.scene_spawned.connect(_on_scene_spawned) # connecting to scene_spawned signal

func _on_scene_spawned(name, spawned_node, scene, data) -> void:
	if name == "shield":
		shield_instance = spawned_node # updating stored node reference each time node is spawned or respawned

func activate(direction: SGFixedVector2) -> void:
	SyncManager.spawn("shield", owner, shield, {})

func deactivate() -> void:
	SyncManager.despawn(shield_instance) # passing node reference to despawn
```
