extends Camera3D

@onready var boat: RigidBody3D = get_node('/root/Main/PlayerController/Boat')

var initial_position: Vector3

func _ready():
	initial_position = global_position

func _process(delta: float):
	global_position.x = initial_position.x + boat.global_position.x
	global_position.z = initial_position.z + boat.global_position.z
