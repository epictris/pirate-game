extends RigidBody3D

@export var scene_2d: PackedScene
@export var float_force := 10
@export var water_drag := 0.01
@export var water_angular_drag := 0.8

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = get_node('/root/Main/WaterPlane')

@onready var probes = $ProbeContainer.get_children()

var submerged := false

@export var sail_node: Node3D
@export var wind_direction: Vector3 = Vector3(0, 0, -1).normalized()
@export var wind_strength: float = 1
@export var rope_slack: float = 0.5
@export var change_slack_rate = 2
@export var max_velocity: float = 5

@export var water_drag_coefficient: float = 0.8
@export var angular_water_drag: float = 2.0
@export var hull_length: float = 10
@export var turn_drag_multiplier: float = 3.0

@export var turn_rate: float = 0.1
@export var max_wheel_angle: float = 0.03

@export var max_sheet_length: float = 10
@export var min_sheet_length: float = 1
@export var sheet_release_speed: float = 3
@export var sheet_haul_speed: float = 1
@export var sail_length = 20

var sail_angle: float = 0.0
var target_sail_angle: float = 0.0
var sail_side: int = 1
var is_running: bool = false

signal player_left_arena()

var player_controlled: bool = false

var arena: Node2D

func join_2d_arena(player: Node2D, join_at_front: bool) -> void:
	arena = scene_2d.instantiate()
	arena.player = player
	if join_at_front:
		player.position = Vector2(get_viewport().get_visible_rect().size.x, 400)
		player.velocity = Vector2(-400, -400)
	else:
		player.position = Vector2(0, 400)
		player.velocity = Vector2(400, -400)
	arena.add_child(player)
	arena.connect("player_took_control", _on_player_took_control)
	arena.connect("player_left_arena", _on_player_left_arena)
	add_child(arena)
	
	
func _on_player_took_control():
	player_controlled = true
	remove_child(arena)

func _on_player_left_arena(left_at_front: bool):
	arena.queue_free()
	var front_direction = global_basis.z
	var boat_length = %CollisionShape3D.shape.get_size().z
	if left_at_front:
		player_left_arena.emit(front_direction * 3 + linear_velocity, Vector3(global_position + front_direction.normalized() * 3) + Vector3.UP)
	else:
		player_left_arena.emit(front_direction * -3 + linear_velocity, Vector3(global_position - front_direction.normalized() * 3) + Vector3.UP)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE and player_controlled:
			if arena:
				add_child(arena)
			player_controlled = false

var wheel_angle: float = 0
var main_sheet_length = 1

func _process(delta):
	if not player_controlled:
		return
	var angle_changed: bool = false
	if Input.is_action_pressed("turn_right") || Input.is_action_just_pressed("turn_right"):
		wheel_angle -= turn_rate * delta
		angle_changed = true
		
	elif Input.is_action_pressed("turn_left") || Input.is_action_just_pressed("turn_left"):
		wheel_angle += turn_rate  * delta
		angle_changed = true
		
	else:
		angle_changed = true
		wheel_angle = lerp(wheel_angle, 0.0, turn_rate)
	
	
	if wheel_angle > 0:
		wheel_angle = min(max_wheel_angle, wheel_angle)
	else:
		wheel_angle = max(-max_wheel_angle, wheel_angle)
		
	if Input.is_action_pressed("increase_slack") || Input.is_action_just_pressed("increase_slack"):
		rope_slack = min(1, rope_slack + change_slack_rate * delta)
	if Input.is_action_pressed("reduce_slack") || Input.is_action_just_pressed("reduce_slack"):
		rope_slack = max(0, rope_slack - change_slack_rate * delta)

func _physics_process(delta: float) -> void:
	rotate_y(wheel_angle)
	update_sail_direction(delta)
	# DebugDraw3D.draw_arrow(global_position + Vector3(0, 0.3, 0), global_position + wind_direction + Vector3(0, 0.3, 0), Color.RED, 0.01)
	apply_wind_force()
	apply_lateral_resistance()
	
	submerged = false
	
	var max_buoyancy_depth = 1.0
	
	for p in probes:
		var depth = water.get_height(p.global_position) - p.global_position.y
		if depth > 0:
			depth = min(depth, max_buoyancy_depth)
			submerged = true
			var buoyant_force = Vector3.UP * depth * float_force
			apply_force(buoyant_force, p.global_position - global_position)
	
	var vertical_damping = 5
	
	if submerged && linear_velocity.y > 0.3:
		apply_central_force(Vector3.DOWN * linear_velocity.y * vertical_damping)
	
func apply_lateral_resistance():
	var right_vector = transform.basis.x
	var forward_vector = transform.basis.z
	var lateral_velocity = linear_velocity.dot(right_vector)
	var forward_velocity = linear_velocity.dot(forward_vector)
	
	var lateral_resistance = -lateral_velocity * right_vector * 5.0
	apply_central_force(lateral_resistance)
	apply_central_force(forward_vector.normalized() * abs(lateral_velocity) * 2)

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if submerged:
		state.linear_velocity *=  1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag
		
	# Then override the roll rotation
	var transform = state.transform
	var basis = transform.basis
	
	# Get current rotation but zero out the roll
	var euler = basis.get_euler()
	euler.z = 0  # Zero out roll (Z-axis)
	
	# Reconstruct the basis without roll
	var new_basis = Basis()
	new_basis = new_basis.rotated(Vector3.UP, euler.y)      # Yaw
	new_basis = new_basis.rotated(new_basis.x, euler.x)     # Pitch

	transform.basis = new_basis
	state.transform = transform
	
	# Also zero out roll angular velocity
	var local_angular_vel = basis.inverse() * state.angular_velocity
	local_angular_vel.z = 0  # Remove roll angular velocity
	state.angular_velocity = basis * local_angular_vel

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
	
	sail_angle = lerp_angle(sail_angle, target_sail_angle, 5.0 * delta)
	
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
	var max_running_angle = lerp(PI/20, PI/2, rope_slack)
	target_sail_angle = sail_side * max_running_angle

func update_sail_side(wind_angle: float):
	var angle_threshold = 0
	
	if wind_angle > angle_threshold:
		sail_side = 1
	elif wind_angle < -angle_threshold:
		sail_side = -1
	
	
func calculate_sail_angle(wind_angle: float) -> float:
	# Apply slack constraints
	var max_angle = lerp(PI/20, PI/2, rope_slack)  # More slack = wider angle range
	
	# Clamp the angle based on rope slack
	return clamp(wind_angle, -max_angle, max_angle)


func apply_wind_force():
	if not sail_node:
		return
	
	var base_force = 100.0
	
	# Get sail orientation vectors
	var sail_forward = sail_node.global_transform.basis.z  # Direction sail is facing  
	var sail_right = -sail_node.global_transform.basis.x     # Right side of sail
	
	# DebugDraw3D.draw_arrow(global_position + Vector3(0, 0.3, 0), global_position + sail_forward * 30 + Vector3(0, 0.3, 0), Color.BLUE, 0.01)
	# DebugDraw3D.draw_arrow(global_position + Vector3(0, 0.3, 0), global_position + sail_right * 30 + Vector3(0, 0.3, 0), Color.GREEN, 0.01)
	

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

		var ship_force = primary_force.length() * global_transform.basis.z * Vector3(1, 0, 1)
		# Apply the forces
		apply_central_force(ship_force)
		# DebugDraw3D.draw_arrow(global_position + Vector3(0, 0.3, 0), global_position + (ship_force) * 2 + Vector3(0, 0.3, 0), Color.YELLOW, 0.01)
