extends Node2D

enum WEAPONS {
		WEAPON_NONE,
		WEAPON_PISTOL,
		WEAPON_BOW,
		WEAPON_RIFLE,
		WEAPON_SWORD,
		WEAPON_KNIFE,
		WEAPON_PAN,
		WEAPON_BOMB,
		WEAPON_GRENADE
}

@export var walk_speed_modifier := 0.0
@export var run_speed_modifier := 0.0
@export var climb_speed_modifier := 0.0
@export var walk_max_speed_modifier := 0.0
@export var run_max_speed_modifier := 0.0
@export var jump_modifier := 0.0
@export var acceleration_modifier := 0.0
@export var deceleration_modifier := 0.0
