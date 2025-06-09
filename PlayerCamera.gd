extends Camera3D

var initial_position: Vector3

func _ready():
	initial_position = global_position

func _process(delta: float):
	var player = get_parent()
	global_position.y = 15
