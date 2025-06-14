extends Node2D
@export var animator : AnimationPlayer = null
@onready var attack_timer : Timer = $attack_timer
var enemies = []
@export var damage := 10.0
var can_attack := true
var direction := 1
var swing_angle = deg_to_rad(159)

func set_direction(dir):
	direction = 1 if dir else -1

func _process(delta: float) -> void:
	rotation += direction * deg_to_rad(5)
	
	if abs(rotation) >= swing_angle:
		expire()

func _on_hitbox_body_entered(body:Node2D) -> void:
	if enemies.find(body) == -1:
		enemies.append(body)
		if body.has_method("take_damage"):
			body.take_damage(damage)

func expire():
	queue_free()