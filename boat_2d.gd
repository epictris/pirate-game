extends Node2D

signal player_left_arena
signal player_took_control

var player: Node2D
var boat_3d: Node3D

func _ready() -> void:
	%FrontExitZone.connect("body_entered", body_exit_front)
	%BackExitZone.connect("body_entered", body_exit_back)
	
func body_exit_back(body: Node2D):
	if body == player:
		player_left_arena.emit(false)

func body_exit_front(body: Node2D):
	if body == player:
		player_left_arena.emit(true)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_E:
			if %Wheel.overlaps_body(player):
				player_took_control.emit()

func _process(delta: float) -> void: 
	var boat: Node2D = %Boat
	boat.rotation = boat_3d.rotation.x
	boat.position.y = 700 - (boat_3d.global_position.y * 250)
