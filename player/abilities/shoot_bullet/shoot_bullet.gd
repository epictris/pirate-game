extends AbilityBase

@export var bullet_scene: PackedScene
@export var explosion_scene: PackedScene

func _ready() -> void:
	super()

func activate(direction: SGFixedVector2) -> void:
	var data = {
		fixed_position = player.fixed_position.copy(),
		direction = direction,
		player_path = player.get_path(),
	}

	SyncManager.spawn("bullet", player.get_parent(), bullet_scene, data)
