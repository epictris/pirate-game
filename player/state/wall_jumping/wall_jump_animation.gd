extends Node2D

@onready var animation_player: NetworkAnimationPlayer = %NetworkAnimationPlayer
@onready var sprite_parent: Node2D = %Node2D

func _network_spawn(data: Dictionary) -> void:
	sprite_parent.scale.x = -1 if data["flip_h"] else 1
	animation_player.play("wall_jump")
