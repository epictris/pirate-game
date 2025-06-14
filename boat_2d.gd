extends Node2D

class_name ShipArena

signal player_left_arena
signal player_took_control

var player: Node2D
var boat_3d: Node3D

const EDGE_BUFFER: float = 1.0 # meters between ship and edge of arena

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_A:
			player_took_control.emit()

func _process(_delta: float) -> void: 
	var boat: Node2D = %Ship
	boat.rotation = boat_3d.rotation.x
	boat.position.y = -boat_3d.global_position.y * 300
	%Water2D.set_position_3d(boat_3d.global_position)
	%Water2D.set_right_direction_3d(Vector3(boat_3d.global_basis.x) * Vector3(1, 0, 1))

func add_player_to_scene(player_to_add: CharacterBody2D) -> void:
	player = player_to_add
	add_child(player)
	player.global_position = %Ship/EntryPoint.global_position
	player.velocity = Vector2(-500, -2300)
