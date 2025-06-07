extends RigidBody3D
class_name Ship

@export var float_force := 1
@export var water_drag := 0
@export var water_angular_drag := 0.2

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = get_node('/root/Main/WaterPlane')

@onready var probes = $ProbeContainer.get_children()

var submerged := false
	


@export var sail_node: Node3D
@export var wind_direction: Vector3 = Vector3(-1, 0, 0).normalized()
@export var wind_strength: float = 0.1
@export var rope_slack: float = 1
@export var max_velocity: float = 5

@export var water_drag_coefficient: float = 0.8
@export var angular_water_drag: float = 2.0
@export var hull_length: float = 10
@export var turn_drag_multiplier: float = 3.0

var sail_angle: float = 0.0
var target_sail_angle: float = 0.0
var sail_side: int = 1
var is_running: bool = false

func _physics_process(delta: float) -> void:
	
	
	update_sail_direction(delta)
	DebugDraw3D.draw_arrow(global_position + Vector3(0, 0.4, 0), global_position + wind_direction * 3 + Vector3(0, 0.4, 0), Color.RED, 0.01)
	apply_wind_force()
	
	submerged = false
	for p in probes:
		var depth = water.get_height(p.global_position) - p.global_position.y 
		if depth > 0:
			submerged = true
			apply_force(Vector3.UP * float_force * gravity, p.global_position - global_position)
	
func _integrate_forces(state: PhysicsDirectBodyState3D):
	if submerged:
		# state.linear_velocity *=  1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag


func update_sail_direction(delta: float):
	var ship_forward = -transform.basis.z
	var wind_angle = ship_forward.signed_angle_to(wind_direction, Vector3.UP)
	
	var wind_angle_abs = abs(wind_angle)
	is_running = abs(sail_angle - wind_angle) > PI && rad_to_deg(wind_angle_abs) > 90 # Sailing with the wind (downwind)
	
	if is_running:
		handle_running_sail(wind_angle)
	else:
		update_sail_side(wind_angle)
		target_sail_angle = calculate_sail_angle(wind_angle)
	
	sail_angle = lerp_angle(sail_angle, target_sail_angle, 2.0 * delta)
	
	if sail_node: 
		sail_node.rotation.y = sail_angle

func handle_running_sail(wind_angle: float):
	# When running (sailing downwind), the sail should be perpendicular to wind
	# and stay on one side unless manually changed
	
	
	if abs(sail_angle) < deg_to_rad(10):  # If sail is nearly centered
		# Choose side based on current wind angle, but with strong hysteresis
		if wind_angle > PI/2:
			sail_side = 1  # Starboard
		elif wind_angle < -PI/2:
			sail_side = -1  # Port
		# Otherwise keep current side
	# Set sail perpendicular to the wind direction, on the chosen side
	var max_running_angle = lerp(0.0, PI/3, rope_slack)
	target_sail_angle = sail_side * max_running_angle

func update_sail_side(wind_angle: float):
	var angle_threshold = 0
	
	if wind_angle > angle_threshold:
		sail_side = 1
	elif wind_angle < -angle_threshold:
		sail_side = -1
	
	
func calculate_sail_angle(wind_angle: float) -> float:
	# Base angle from wind direction
	var optimal_angle = wind_angle * 0.5  # Sails work best at ~45° to wind
	
	# Apply slack constraints
	var max_angle = lerp(0.0, PI/3, rope_slack)  # More slack = wider angle range
	
	# Clamp the angle based on rope slack
	return clamp(optimal_angle, -max_angle, max_angle)


func apply_wind_force():
	if not sail_node:
		return
	
	var base_force = 100.0
	
	# Get sail orientation vectors
	var sail_forward = sail_node.global_transform.basis.z  # Direction sail is facing  
	var sail_right = -sail_node.global_transform.basis.x     # Right side of sail
	
	DebugDraw3D.draw_arrow(global_position + Vector3(0, 0.3, 0), global_position + sail_forward * 30 + Vector3(0, 0.3, 0), Color.BLUE, 0.01)
	DebugDraw3D.draw_arrow(global_position + Vector3(0, 0.3, 0), global_position + sail_right * 30 + Vector3(0, 0.3, 0), Color.GREEN, 0.01)
	

#	if is_in_no_go_zone:
		# Luffing - chaotic forces
#		var turbulence = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * 30
#		apply_central_force(turbulence)
#		return
	
	# Calculate how wind hits the sail
	var wind_angle_to_sail = wind_direction.dot(sail_right.normalized())

	# Only generate force if wind hits the sail face (positive dot product)
	if abs(wind_angle_to_sail) > 0.1:  # Small threshold to avoid tiny forces
		var wind_strength_on_sail = wind_strength * abs(wind_angle_to_sail)
		
		# Calculate force direction - wind pushes sail in the direction it's facing
		var primary_force = sail_forward * wind_strength_on_sail * base_force

		var ship_force = primary_force.length() * global_transform.basis.z
		# Apply the forces
		apply_central_force(ship_force)
		DebugDraw3D.draw_arrow(global_position + Vector3(0, 0.3, 0), global_position + (ship_force) * 2 + Vector3(0, 0.3, 0), Color.YELLOW, 0.01)


		# Torque from sail position
		# var sail_arm = sail_node.global_position - global_position
		# var torque = sail_arm.cross(primary_force) * 0.1
		# apply_torque(torque)
		
		# Debug info
		if Input.is_action_just_pressed("ui_accept"):  # For testing
			print("Wind angle to sail: ", wind_angle_to_sail)
			print("Force direction: ", (primary_force).normalized())
			print("Ship forward: ", -transform.basis.z)
