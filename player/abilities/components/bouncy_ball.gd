extends AbilityBase

@export var ball: PackedScene

func _ready() -> void:
	super()

func activate(direction: SGFixedVector2) -> void:
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
