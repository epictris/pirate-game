extends AbilityBase

@export var axe_scene: PackedScene

func activate(direction: SGFixedVector2) -> void:
	var axe_position: SGFixedVector2 = player.fixed_position.add(direction.mul(FI.ONE * 70))
	SyncManager.spawn(
		"axe", 
		player.get_parent(),
		axe_scene, 
		{
			"fixed_position_x": axe_position.x,
			"fixed_position_y": axe_position.y,
			"direction": direction
		}
	)

func _update() -> void:
	pass
