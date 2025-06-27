extends SGArea2D

@onready var timer: NetworkTimer = %Timer

func _network_spawn(data: Dictionary) -> void:
	return
	timer.timeout.connect(_despawn)

func _despawn() -> void:
	SyncManager.despawn(self)
