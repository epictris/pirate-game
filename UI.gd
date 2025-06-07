extends CanvasLayer

@onready var player = get_node("/root/Main/PlayerController")

func _ready():
	player.wheel_angle_changed.connect(_on_wheel_angle_changed)
	player.boat_rotation_changed.connect(_on_boat_rotation_changed)
	
func _on_wheel_angle_changed(new_angle: float):
	$Wheel.rotation = rad_to_deg(-new_angle)
	
func _on_boat_rotation_changed(new_angle: float):
	$BoatHUD.rotation = new_angle
