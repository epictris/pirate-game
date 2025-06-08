extends CharacterBody2D

@onready var player: CharacterBody2D = $"."

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

func _physics_process(delta: float) -> void:
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
	
	if direction < 0:
		player.transform.x.x = -1 # Flip the player to the right
	elif direction > 0:
		player.transform.x.x = 1
	
	move_and_slide()
