extends ColorRect

var time: float

func _process(delta):
	time += delta
	material.set_shader_parameter("wave_time", time)

