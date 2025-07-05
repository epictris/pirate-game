extends AbilityBase

@export var axe_scene: PackedScene

func _postprocess_on_activated(direction: SGFixedVector2) -> void:
	player.activate_ability(self)
	var axe_position: SGFixedVector2 = player.fixed_position.add(direction.mul(FI.ONE * 30))
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

func _postprocess_on_deactivated(_direction: SGFixedVector2) -> void:
	player.deactivate_ability(self)
