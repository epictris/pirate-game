extends Node2D

@onready var sprite_parent: Node2D = %SpriteParent
@onready var animation_player: NetworkAnimationPlayer = %NetworkAnimationPlayer

func _network_spawn(data: Dictionary) -> void:
	if data["flip_h"]:
		sprite_parent.scale.x = -1
	animation_player.play("sliding")
