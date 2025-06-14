extends Node2D

@onready var sword_instance := preload("res://scenes/weapons/sword_instance.tscn")

func dir_attack(is_facing_right):
	var instance = sword_instance.instantiate()
	instance.set_direction(is_facing_right)
	add_child(instance)