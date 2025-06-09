extends CharacterBody3D

signal body_entered_area(body)

@export var acceleration: float = 1.0
@export var max_swim_speed: float = 3
@export var drag: float = 0.95

var lateral_velocity: Vector2 = Vector2.ZERO
var is_swimming: bool = false

func apply_buoyancy(water: MeshInstance3D):
	var water_height = water.get_height(global_position)
	global_position.y = max(water_height, global_position.y)
	if water_height == global_position.y:
		is_swimming = true
	else:
		is_swimming = false
	
func handle_swimming_movement(delta: float) -> void:	
	var move_direction = Vector2.ZERO
	
	if Input.is_action_just_pressed("move_up") || Input.is_action_pressed("move_up"):
		move_direction.x -= 1
		
	if Input.is_action_just_pressed("move_down") || Input.is_action_pressed("move_down"):
		move_direction.x += 1
		
	if Input.is_action_just_pressed("move_right") || Input.is_action_pressed("move_right"):
		move_direction.y += 1
		
	if Input.is_action_just_pressed("move_left") || Input.is_action_pressed("move_left"):
		move_direction.y -= 1
	
	move_direction = move_direction.normalized()
	
	lateral_velocity += move_direction
	
	lateral_velocity *= drag
	
	if lateral_velocity.length() > max_swim_speed:
		lateral_velocity = lateral_velocity.normalized() * max_swim_speed
		
	velocity.z = lateral_velocity.x
	velocity.x = lateral_velocity.y
	
func _physics_process(delta: float) -> void:
	if is_swimming:
		handle_swimming_movement(delta)
		
	velocity += get_gravity() * delta
	move_and_slide()
	
	var collision = get_last_slide_collision()
	if collision:
		body_entered_area.emit(collision)
