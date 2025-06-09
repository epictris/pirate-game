extends CharacterBody2D

enum {
	SPINNING,
	BULLET,
	THROWN
}

@export var collider : Area2D = null
@export var projectile_type := BULLET
@export var speed := 500.0
@export var damage := 10.0
@export var lifetime := 2.0
@export var spin_speed := 5.0

func _process(delta: float) -> void:
	match projectile_type:
		SPINNING:
			# Rotate the projectile
			rotation += spin_speed * delta
			position += Vector2(speed * delta, 0).rotated(rotation)
		BULLET:
			# Move the projectile forward
			position += Vector2(speed * delta, 0).rotated(rotation)
		THROWN:
			# Apply gravity to the thrown projectile
			position += Vector2(speed * delta, 0).rotated(rotation)
			position.y += 9.8 * delta  # Simple gravity effect
	move_and_collide(Vector2.ZERO)  # Ensure the projectile moves and checks for collisions

func _physics_process(delta: float) -> void:
	if lifetime > 0:
		lifetime -= delta
		if lifetime <= 0:
			queue_free()  # Remove the projectile after its lifetime expires
	else:
		queue_free()  # Remove the projectile if lifetime is not set
	