extends Node

@export var player_node: CharacterBody2D = null
@export var ship_node: Node2D = null


@export var amplitude: float = 0.1
@export var frequency: float = 3.14
@export var speed: float = 1.5
@export var offset: float = 0.0
@export var time: float = 0.0 # Scale for the time variable

@export var wave_length: float = 30.0 # Length of the wave

# func _process(delta: float) -> void:
# 	var prev_pos: Vector2 = ship_node.global_position
# 	var prev_rotation := ship_node.rotation

# 	offset += delta * speed # Update the offset to animate the wave
# 	var wave_value: float = get_wave_gradient_at(offset)
	
# 	ship_node.position.y += wave_value
# 	ship_node.rotation = atan(wave_value / 5)

# 	var angle_difference = ship_node.rotation - prev_rotation
# 	var vector_from_origin_to_current_position: Vector2 = ship_node.global_position - player_node.global_position
# 	var vector_from_origin_to_new_position: Vector2 = vector_from_origin_to_current_position.rotated(angle_difference)
# 	var player_new_position : Vector2 = ship_node.global_position + vector_from_origin_to_new_position
# 	player_node.global_position = player_new_position


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
	var player_new_position: Vector2 = ship_node.global_position - vector_from_origin_to_new_position
	
	player_node.ship_rotation = angle_diff
	player_node.global_position = player_new_position if player_node.is_on_floor() or player_node.on_ladder else player_node.global_position
	ship_node.rotation = ship_new_rotation

func get_wave_gradient_at(x: float) -> float:
	return amplitude * cos(frequency + x)
