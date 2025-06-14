extends RigidBody2D

@export var health_component : Node = null

func take_damage(dmg):
	health_component.take_damage(dmg)

func on_death():
	queue_free()