extends Node

# 1. SyncManager calls _network_preprocess on all nodes in network_sync group. This function should only be used to save the input for the current tick on applicable nodes.
# 2. SyncManager calls _network_process on ONLY the GameLoop node. No other nodes should implement the _network_process function.

func _network_process(_input: Dictionary) -> void:

	# 1. Update environmental systems that affect everything else
	var environment = get_tree().get_nodes_in_group("environment")
	for item in environment:
		if item.has_method("_update"):
			item._update()

	# 2. Update player input and movement
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		if player.has_method("_update"):
			player._update()

	# 3. Update projectiles (potentially spawned by players)
	var projectiles = get_tree().get_nodes_in_group("projectile")
	for projectile in projectiles:
		if projectile.has_method("_update"):
			projectile._update()
