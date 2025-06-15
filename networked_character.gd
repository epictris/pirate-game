extends CharacterBody2D

# Movement variables
@export var speed: float = 500.0
@export var jump_velocity: float = -1000.0
@export var acceleration: float = 2000.0
@export var friction: float = 1200.0
@export var air_acceleration: float = 500.0
@export var air_friction: float = 200.0

# Physics
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# print("is multiplayer authority: ", is_multiplayer_authority(), ", id: ", multiplayer.get_unique_id())
	if !is_multiplayer_authority():
		return
	# Handle gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	# Handle horizontal movement
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if is_on_floor():
		# Ground movement - full responsiveness
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:
		# Air movement - reduced responsiveness
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * speed, air_acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, air_friction * delta)
	
	# Move the character
	move_and_slide()
	sync_position.rpc(position)

@rpc("any_peer", "call_remote", "unreliable")
func sync_position(pos: Vector2):
	position = pos

# External velocity control functions
func set_velocity_external(new_velocity: Vector2):
	"""Set velocity externally - useful for knockback, moving platforms, etc."""
	velocity = new_velocity

func add_velocity_external(additional_velocity: Vector2):
	"""Add to current velocity externally - useful for impulses"""
	velocity += additional_velocity

func set_horizontal_velocity_external(horizontal_velocity: float):
	"""Set only horizontal velocity externally"""
	velocity.x = horizontal_velocity

func set_vertical_velocity_external(vertical_velocity: float):
	"""Set only vertical velocity externally"""
	velocity.y = vertical_velocity

# Optional: Add coyote time for better jumping feel
@export var coyote_time: float = 0.1
var coyote_timer: float = 0.0
var was_on_floor: bool = false

func _ready():
	# Alternative physics process with coyote time
	pass

func _physics_process_with_coyote(delta):
	# Handle gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
		# Coyote time - allow jumping shortly after leaving ground
		if was_on_floor:
			coyote_timer = coyote_time
		else:
			coyote_timer -= delta
	else:
		coyote_timer = coyote_time
	
	# Handle jump (with coyote time)
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or coyote_timer > 0):
		velocity.y = jump_velocity
		coyote_timer = 0  # Consume coyote time
	
	# Handle horizontal movement
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if is_on_floor():
		# Ground movement - full responsiveness
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:
		# Air movement - reduced responsiveness
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * speed, air_acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, air_friction * delta)
	
	# Store floor state for next frame
	was_on_floor = is_on_floor()
	
	# Move the character
	move_and_slide()
