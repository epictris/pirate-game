extends RigidBody2D

@export var health_component : Node = null
@export var size2 := 20.0
@onready var collision_shape : CollisionShape2D = CollisionShape2D.new()
var shape : RectangleShape2D = RectangleShape2D.new()

func _ready():
	shape.size = Vector2(size2,size2)
	collision_shape.set_shape(shape)
	print(collision_shape.shape.size)
	add_child(collision_shape)
	var hitbox_shape = collision_shape.duplicate()
	health_component.add_child(hitbox_shape)

func on_death():
	queue_free()
