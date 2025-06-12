extends Node2D

@onready var wave_node: Line2D = $Waves

@export var amplitude: float = 0.1
@export var frequency: float = 3.14
@export var speed: float = 1.5
@export var offset: float = 0.0
@export var time: float = 0.0  # Scale for the time variable


@export var wave_length: float = 30.0  # Length of the wave

var prev_pos := Vector2.ZERO

func _ready():
	GlobalScenes.set_current_2d_scene(self)  # Set this scene as the current 2D scene

func _process(delta: float) -> void:
	offset += delta * speed  # Update the offset to animate the wave
	var wave_value: float = get_wave_gradient_at(offset)
	# ship.position.y += wave_value
	# ship.rotation = atan(wave_value/5)
	update_wave()

func get_wave_gradient_at(x: float) -> float:
	return amplitude * cos(frequency + x)


func update_wave():
	var points: PackedVector2Array = []
	for i in range(0, wave_length):
		var x: float = i * 10
		var y: float = get_wave_gradient_at(time + i + offset)*20
		points.append(Vector2(x, y))
	
	wave_node.points = points
