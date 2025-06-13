extends Node2D

@export var player_class: Node2D = null

var walk_speed_modifier: float = player_class.walk_speed_modifier if player_class != null else 0.0
var run_speed_modifier : float = player_class.run_speed_modifier if player_class != null else 0.0
var climb_speed_modifier : float = player_class.climb_speed_modifier if player_class != null else 0.0
var walk_max_speed_modifier : float = player_class.walk_max_speed_modifier if player_class != null else 0.0
var run_max_speed_modifier : float = player_class.run_max_speed_modifier if player_class != null else 0.0
var jump_modifier : float = player_class.jump_modifier if player_class != null else 0.0
var acceleration_modifier :	float = player_class.acceleration_modifier if player_class != null else 0.0
var deceleration_modifier : float = player_class.deceleration_modifier if player_class != null else 0.0
