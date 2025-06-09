extends RigidBody3D

@export var scene_2d: PackedScene

signal player_left_arena()

var player_controlled: bool = false

var arena: Node2D

func join_2d_arena(player: Node2D, join_at_front: bool) -> void:
	arena = scene_2d.instantiate()
	arena.player = player
	if join_at_front:
		player.position = Vector2(get_viewport().get_visible_rect().size.x, 400)
		player.velocity = Vector2(-400, -400)
	else:
		player.position = Vector2(0, 400)
		player.velocity = Vector2(400, -400)
	arena.add_child(player)
	arena.connect("player_took_control", _on_player_took_control)
	arena.connect("player_left_arena", _on_player_left_arena)
	add_child(arena)
	
	
func _on_player_took_control():
	player_controlled = true
	remove_child(arena)

func _on_player_left_arena(left_at_front: bool):
	arena.queue_free()
	var front_direction = global_basis.z
	var boat_length = %CollisionShape3D.shape.get_size().z
	if left_at_front:
		player_left_arena.emit(front_direction * 3, Vector3(global_position + front_direction.normalized() * 3) + Vector3.UP)
	else:
		player_left_arena.emit(front_direction * -3, Vector3(global_position - front_direction.normalized() * 3) + Vector3.UP)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE and player_controlled:
			if arena:
				add_child(arena)
			player_controlled = false
