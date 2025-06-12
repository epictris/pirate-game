extends Node

@export var water: MeshInstance3D

func _physics_process(delta: float):
	var buoyant_nodes = get_tree().get_nodes_in_group("buoyant")
	for node in buoyant_nodes:
		if node.has_method("apply_buoyancy"):
			node.apply_buoyancy(water)
