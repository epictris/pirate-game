extends Node

#nodes
@export var parent_node: CharacterBody2D = null
# @export var class_node: Node2D = null

#exported variables
@export var walk_speed : float = 300.0
@export var run_speed : float = 500.0
@export var climb_speed : float = 150.0
@export var walk_max_speed : float = 200.0
@export var run_max_speed : float = 400.0
@export var jump : float = -800.0
@export var acceleration : float = 8.0
@export var deceleration : float = 1500.0
@export var dash_speed: float = 500.0

var is_facing_right = true
const gravity = 2500
const term_velocity = 10000
var running := false
var off_edge_timer = 0.0
var off_edge := false
var dashing := false
var can_dash := true
var dash_timer := 0.0
var dash_cooldown := 1.0

func _ready():
	parent_node = get_parent() as CharacterBody2D if parent_node == null else parent_node
	if parent_node == null:
		push_error("MovementComponent requires a parent of type CharacterBody2D.")
		return
	print(run_speed)

func _input(event: InputEvent) -> void:
	#Handle run input
	if event.is_action_pressed("run"):
		running = not running
		parent_node.state = parent_node.animation_states.RUN
		if running and parent_node.velocity.x != 0:
			parent_node.player_sprite.play("run")

	elif event.is_action_released("run"):
		running = false
		parent_node.state = parent_node.animation_states.WALK if parent_node.velocity.x != 0 else parent_node.animation_states.IDLE
		parent_node.player_sprite.play("walk" if not parent_node.is_on_floor() else "idle")
	
	if event.is_action_pressed("climb_up") or event.is_action_pressed("climb_down"):
		parent_node.on_ladder = parent_node.can_climb
		if parent_node.on_ladder:
			# Climb up or down the ladder
			var climb_direction = Input.get_axis("climb_up", "climb_down")
			if climb_direction != 0:
				parent_node.velocity = Vector2(0.0,climb_direction * climb_speed).rotated(-parent_node.ship_rotation)
				parent_node.state = parent_node.animation_states.CLIMB
				parent_node.player_sprite.play("climb")
			else:
				parent_node.velocity.y = 0
				parent_node.state = parent_node.animation_states.IDLE
				parent_node.player_sprite.play("idle")
		else:
			# If not on a ladder, reset climbing state
			parent_node.state = parent_node.animation_states.IDLE
			parent_node.player_sprite.play("idle")


func _physics_process(delta: float) -> void:
	#Handle jump input
	if Input.is_action_just_pressed("jump") and (parent_node.is_on_floor() or off_edge_timer < 0.6) and not parent_node.on_ladder:
		parent_node.velocity += Vector2(0.0,jump).rotated(GlobalShipData.ship_rotation)
	
	# Add the gravity.
	if not parent_node.is_on_floor() and not parent_node.on_ladder:
		off_edge_timer += 0.1
		parent_node.velocity.y += gravity * 1.1 * delta
		if parent_node.velocity.y > term_velocity:
			parent_node.velocity.y = term_velocity
	elif parent_node.on_ladder and Input.get_axis("climb_up", "climb_down") == 0:
		parent_node.velocity.y = 0
		parent_node.player_sprite.pause()
	else:
		off_edge_timer = 0.0
	
	var max_speed = run_max_speed if running else walk_max_speed
	var move_speed = run_speed if running else walk_speed
	
	# Get the input direction and handle the movement/deceleration. 
	var direction = Input.get_axis("move_left", "move_right")
	if dashing:
		parent_node.velocity.x = direction * dash_speed
		dash_timer += 0.1 * delta
		print(dash_timer)
	elif direction != 0:
		parent_node.is_facing_right = direction > 0
		# player_sprite.scale.x = -1 * abs(player_sprite.scale.x) if not is_facing_right else abs(player_sprite.scale.x)
		parent_node.velocity.x = move_toward(parent_node.velocity.x, direction * max_speed, move_speed * acceleration * delta)
	else:
		parent_node.velocity.x = move_toward(parent_node.velocity.x, direction * max_speed, deceleration * delta)

	if dash_timer > 0.3 and dashing:
		dashing = false
		dash_timer = 0.0
	elif dash_timer > dash_cooldown and not dashing:
		can_dash = true
		dash_timer = 0.0
	dash_timer += delta if not dashing and not can_dash else dash_timer
		

	parent_node.move_and_slide()
	
