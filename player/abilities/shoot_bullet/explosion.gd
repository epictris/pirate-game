extends Node2D

@onready var animation_player: NetworkAnimationPlayer = %NetworkAnimationPlayer
@onready var timer: NetworkTimer = %NetworkTimer

func _ready() -> void:
	timer.timeout.connect(_on_animation_finished)

func _network_spawn(data: Dictionary) -> void:
	position = data["fixed_position"].to_float()
	animation_player.play("EXPLODE")
	timer.start()

func _on_animation_finished() -> void:
	SyncManager.despawn(self)
