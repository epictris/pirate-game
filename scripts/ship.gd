extends Node2D

@onready var point : Node2D = $point

var point_previous_position := Vector2.ZERO
var point_current_position := Vector2.ZERO

var ship_current_position := Vector2.ZERO
var ship_previous_position := Vector2.ZERO

func _process(delta: float) -> void:
    point_current_position = point.global_position
    ship_current_position = (global_position - point_current_position).normalized()
    GlobalShipData.ship_position_change = get_position_change()
    point_previous_position = point_current_position
    ship_previous_position = ship_current_position

func get_position_change() -> Vector2:
    var position_change := ship_current_position - ship_previous_position
    return position_change.normalized()