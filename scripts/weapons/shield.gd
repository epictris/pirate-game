extends Node2D
var shield_up := true
@onready var shield_timer : Timer = $shield_cooldown
@onready var collider : Area2D = $collider
@onready var collider_shape : CollisionShape2D = $collider/CollisionShape2D

func drop_shield():
	shield_up = false
	collider_shape.disabled = true
	shield_timer.start()

func _on_shield_cooldown_timeout() -> void:
	shield_up = true
	collider_shape.disabled = false


func _on_collider_body_entered(body:Node2D) -> void:
	if body.is_in_group("projectile"):
		drop_shield()

func _on_collider_area_entered(area:Area2D) -> void:
	if area.is_in_group("projectile"):
		drop_shield()
