extends Node2D

@onready var sprite: Sprite2D = %Sprite2D

func _network_spawn(data: Dictionary) -> void:
	sprite.flip_h = data["flip_h"]
