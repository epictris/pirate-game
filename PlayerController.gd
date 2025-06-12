extends Node

var current_2d_scene: Node2D
@export var player_scene_3d: PackedScene
@export var player_scene_2d: PackedScene
@export var player_3d: CharacterBody3D

@export var boarded_boat: Node3D

var player_2d: CharacterBody2D

var can_join_scene: bool = true

func _ready():
	if player_3d:
		player_3d.connect("body_entered_area", _on_player_3d_collision)
		player_3d.connect("joined_boat", player_joined_boat)
	
func _process(delta: float) -> void:
	if player_3d:
		%Camera3D.global_position.x = player_3d.global_position.x
		%Camera3D.global_position.z = player_3d.global_position.z + 5
	
	elif boarded_boat:
		%Camera3D.global_position.x = boarded_boat.global_position.x
		%Camera3D.global_position.z = boarded_boat.global_position.z + 5

func player_joined_boat(boat: Node3D):
	if boat.has_method("join_2d_arena"):
		player_3d.queue_free()
		boarded_boat = boat
		boarded_boat.connect("player_left_arena", player_left_boat)
		boarded_boat.join_2d_arena(player_scene_2d.instantiate(), true)

func _on_player_3d_collision(collision: KinematicCollision3D) -> void:
	return
	# var collided_with: Node3D = collision.get_collider()
	#
	# print(collision.get_position())
	# print(collided_with.global_position)
	#
	# var collision_angle = Vector2(collision.get_position().x, collision.get_position().z).direction_to(Vector2(collided_with.global_position.x, collided_with.global_position.z)).dot(Vector2(collided_with.global_basis.z.x, collided_with.global_basis.z.z))
	#
	# if collided_with.has_method("join_2d_arena"):
	# 	player_3d.queue_free()
	# 	boarded_boat = collided_with
	# 	boarded_boat.connect("player_left_arena", player_left_boat)
	# 	collided_with.join_2d_arena(player_scene_2d.instantiate(), collision_angle < 0)
	#
	# get_tree().create_timer(0.5).timeout.connect(reset_timer)
	
func player_left_boat(velocity: Vector3, location: Vector3):
	player_3d = player_scene_3d.instantiate()
	player_3d.velocity = velocity
	player_3d.connect("body_entered_area", _on_player_3d_collision)
	player_3d.connect("joined_boat", player_joined_boat)
	add_child(player_3d)
	player_3d.global_position = location
	boarded_boat.disconnect("player_left_arena", player_left_boat)
	boarded_boat = null

func reset_timer():
	can_join_scene = true
