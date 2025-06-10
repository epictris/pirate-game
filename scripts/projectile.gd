extends CharacterBody2D

enum {
	SPINNING,
	BULLET,
	THROWN
}

@export var collider_path: NodePath
@onready var collider: Area2D = get_node(collider_path) if collider_path else null

@export var projectile_type := BULLET
@export var speed := 1000.0
@export var damage := 10.0
@export var lifetime := 2.0
@export var spin_speed := 5.0

func _ready():
	if collider:
		collider.area_entered.connect(_on_area_entered)
		collider.body_entered.connect(_on_body_entered)
	else:
		print("Collider not found at path: ", collider_path) 


func _physics_process(delta: float) -> void:
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
	if lifetime > 0:
		lifetime -= delta
		if lifetime <= 0:
			queue_free()  # Remove the projectile after its lifetime expires
	else:
		queue_free()  # Remove the projectile if lifetime is not set
	

func expire() -> void:
	queue_free()  # Remove the projectile immediately

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)  # Call the take_damage method on the area
	expire()

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)  # Call the take_damage method on the body
	expire()  # Remove the projectile after hitting a body