extends Node

@export var shield: PackedScene
var shield_instance: Node

func _ready() -> void:
	SyncManager.scene_spawned.connect(_on_scene_spawned)

func activate(direction: SGFixedVector2) -> void:
	SyncManager.spawn("shield", owner, shield, {})

func deactivate() -> void:
	SyncManager.despawn(shield_instance)


func override_movement(player: Player) -> bool:
	return false

func _on_scene_spawned(name, spawned_node, scene, data) -> void:
	if name == "shield":
		shield_instance = spawned_node
