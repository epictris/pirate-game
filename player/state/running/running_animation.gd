extends Node2D

@onready var animation_player: NetworkAnimationPlayer = %NetworkAnimationPlayer
@onready var sprite: Sprite2D = %Sprite2D

func _network_spawn(data: Dictionary) -> void:
	sprite.flip_h = data["flip_h"]
	animation_player.play("running")
