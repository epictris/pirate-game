extends Node3D

signal wheel_angle_changed(new_angle)
signal boat_rotation_changed(new_angle)

@onready var boat: RigidBody3D = get_node('/root/Main/PlayerController/Boat')

@export var turn_rate: float = 0.1
@export var max_wheel_angle: float = 0.03

@export var max_sheet_length: float = 10
@export var min_sheet_length: float = 1
@export var sheet_release_speed: float = 3
@export var sheet_haul_speed: float = 1
@export var sail_length = 20

var wheel_angle: float = 0
var main_sheet_length = 1

func _process(delta):
	var angle_changed: bool = false
	if Input.is_action_pressed("turn_right") || Input.is_action_just_pressed("turn_right"):
		wheel_angle -= turn_rate * delta
		angle_changed = true
		
	if Input.is_action_pressed("turn_left") || Input.is_action_just_pressed("turn_left"):
		wheel_angle += turn_rate  * delta
		angle_changed = true
	
	if wheel_angle > 0:
		wheel_angle = min(max_wheel_angle, wheel_angle)
	else:
		wheel_angle = max(-max_wheel_angle, wheel_angle)
		
	if angle_changed:
		wheel_angle_changed.emit(wheel_angle)
	
func _physics_process(delta: float) -> void:
	boat.rotate_y(wheel_angle)
	boat_rotation_changed.emit(-(boat.rotation.y - PI/2))
