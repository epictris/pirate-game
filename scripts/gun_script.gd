extends Node2D

@export var projectile: PackedScene
@onready var barrel: Node2D = $body/barrel

func _ready():
	load(projectile.resource_path)

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		shoot()
	look_at(get_global_mouse_position())

func shoot():
	if not barrel:
		print("Barrel node not found.")
		return
	
	var projectile_instance = projectile.instantiate()
	if not projectile_instance:
		print("Failed to instance projectile.")
		return
	
	GlobalScenes.get_current_2d_scene().add_child(projectile_instance)
	projectile_instance.global_position = barrel.global_position
	projectile_instance.global_rotation = barrel.global_rotation
	projectile_instance.velocity = Vector2(500, 0).rotated(barrel.global_rotation)
	
