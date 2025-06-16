extends StaticBody2D

@export var collider : CollisionShape2D = null

var is_open := false

func toggle_door():
	if is_open:
		is_open = false
		collider.disabled = false
	else:
		is_open = true
		collider.disabled = true
