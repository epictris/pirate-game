extends AbilityBase

@export var ball: PackedScene

func _ready() -> void:
	super()

func _postprocess_on_activated(direction: SGFixedVector2) -> void:
	player.activate_ability(self)
	SyncManager.spawn("ball", player.get_parent(), ball, {
		"fixed_position": {
			"x": player.fixed_position_x,
			"y": player.fixed_position_y,
		},
		"direction": {
			"x": direction.x,
			"y": direction.y
		}
	})

func _postprocess_on_deactivated(_direction: SGFixedVector2) -> void:
	player.deactivate_ability(self)
