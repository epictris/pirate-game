extends CharacterBody2D

enum Layers{
	LEVEL = 0b0001,
	FALLTHROUGH = 0b0010,
}
var collision_mask_default := collision_mask

var collision_mask_fallthrough = collision_mask & ~Layers.FALLTHROUGH

@onready var player: CharacterBody2D = $"."
@onready var weapon_point: Node2D = $weapon_point

@export var speed := 400
@export var max_speed := 300
@export var jump := -800
@export var acceleration := 8
const gravity = 2500
const term_velocity = 10000
var is_facing_right = true
var direction = 0
var is_attacking = false
var off_edge_timer = 0.0
var off_edge := false

func _ready():
	collision_mask_default = collision_mask
	collision_mask_fallthrough = collision_mask & ~Layers.FALLTHROUGH

func _physics_process(delta: float) -> void:

	if Input.is_action_pressed("drop_down"):
		#if we're holding down, apply the collision mask to not collide with the one-way platforms
		collision_mask = collision_mask_fallthrough
	else:
		#make sure we are colliding with them otherwise
		collision_mask = collision_mask_default
	
	# Add the gravity.
	if not is_on_floor():
		off_edge_timer += 0.1
		velocity.y += gravity * 1.1 * delta
		if velocity.y > term_velocity:
			velocity.y = term_velocity
	else:
		off_edge_timer = 0.0

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or off_edge_timer < 0.6):
		velocity.y = jump

	direction = Input.get_axis("move_left", "move_right") * max_speed
	
	# Get the input direction and handle the movement/deceleration. 
	velocity.x = move_toward(velocity.x, direction, speed * acceleration * delta)

	# Your movement logic...

	move_and_slide()
