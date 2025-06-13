extends Node

@export var player_node: CharacterBody2D = null
@export var ship_node: Node2D = null
@export var wave_node: Line2D = null
@export var velocity_visualizer: RayCast2D = null

var player_velocity_from_ship: Vector2 = Vector2.ZERO

@export var amplitude: float = 0.1
@export var frequency: float = 3.14
@export var speed: float = 1.5
@export var offset: float = 0.0
@export var time: float = 0.0 # Scale for the time variable

@export var wave_length: float = 30.0 # Length of the wave

func _process(delta: float) -> void:
	offset += delta * speed  # Update the offset to animate the wave
	var wave_value: float = get_wave_gradient_at(offset)
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

func _physics_process(delta: float) -> void:
	var prev_pos: Vector2 = ship_node.global_position
	var prev_rotation := ship_node.rotation
	offset += delta * speed # Update the offset to animate the wave
	var wave_value: float = get_wave_gradient_at(offset)
	
	var ship_new_rotation = atan(wave_value / 5)

	# ship_node.position.y += wave_value
	
	var angle_diff = ship_new_rotation - prev_rotation
	var vector_from_origin_to_current_position: Vector2 = ship_node.global_position - player_node.global_position
	var vector_from_origin_to_new_position: Vector2 = vector_from_origin_to_current_position.rotated(angle_diff)
	var vector_from_current_position_to_new_position: Vector2 = vector_from_origin_to_new_position - vector_from_origin_to_current_position
	var player_new_position: Vector2 = ship_node.global_position - vector_from_origin_to_new_position
	
	GlobalShipData.ship_rotation = velocity_visualizer.global_rotation
	
	# player_velocity_from_ship += vector_from_current_position_to_new_position
	# velocity_visualizer.target_position = velocity_visualizer.position - vector_from_current_position_to_new_position*10
	# if vector_from_current_position_to_new_position.y > 0.1:
	# 	print("Player Velocity from Ship: ", vector_from_current_position_to_new_position.length())
	player_node.ship_rotation = angle_diff
	player_node.global_position = player_new_position if player_node.is_on_floor() or player_node.on_ladder else player_node.global_position
	ship_node.rotation = ship_new_rotation
	
	# player_node.velocity -= vector_from_current_position_to_new_position if not player_node.on_ladder or player_node.is_on_floor() else player_node.velocity
