extends Node

func _ready():
	get_parent().set_meta("resolve_collision", _redirect)

func _redirect(data: Dictionary) -> void:
	var parent_rotation = SGFixed.vector2(FI.ONE, 0).rotated(get_parent().fixed_rotation)
	data.collider.velocity = parent_rotation.mul(data.collider.velocity.length()).mul(FI.ONE_POINT_ONE)
