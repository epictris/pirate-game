extends CharacterBody2D

enum Layers{
	LEVEL = 0b0001,
	FALLTHROUGH = 0b0010,
	LADDERS = 0b0100,
}

enum animation_states {
	IDLE,
	WALK,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	DAMAGE,
	DIE
}

var collision_mask_default := collision_mask

var collision_mask_fallthrough = collision_mask & ~Layers.FALLTHROUGH

@onready var health_component: Node = $health_component
@onready var player: CharacterBody2D = $"."
@onready var weapon_point: Node2D = $weapon_point
@onready var player_sprite: AnimatedSprite2D = $player_sprite
@onready var ladder_collider: Area2D = $ladder_collider

@export var respawn_point: Node2D = null
@export var walk_speed := 300
@export var run_speed := 500
@export var walk_max_speed := 200
@export var run_max_speed := 400
@export var jump := -800
@export var acceleration := 8
@export var deceleration := 1500
const gravity = 2500
const term_velocity = 10000
var is_facing_right = true
var direction = 0
var is_attacking = false
var off_edge_timer = 0.0
var off_edge := false
var respawn_timer := 0.0
var state = animation_states.IDLE
var running := false


func _ready():
	collision_mask_default = collision_mask
	collision_mask_fallthrough = collision_mask & ~Layers.FALLTHROUGH
	ladder_collider.body_entered.connect(on_ladder_entered)
	ladder_collider.area_entered.connect(on_ladder_entered)

func handle_states():
	match state:
		animation_states.IDLE:
			if velocity.x != 0:
				if running:
					player_sprite.play("run")
					state = animation_states.RUN
				else:
					player_sprite.play("walk")
					state = animation_states.WALK
			else:
				player_sprite.play("idle")
		animation_states.WALK:
			if velocity.x == 0:
				state = animation_states.IDLE
			elif is_on_floor():
				player_sprite.play("walk")
			else:
				player_sprite.play("fall")
		animation_states.JUMP:
			if not is_on_floor():
				player_sprite.play("jump")
			else:
				state = animation_states.IDLE
		# animation_states.ATTACK:
		# 	if not is_attacking:
		# 		state = animation_states.IDLE
		# animation_states.DAMAGE:
		# 	if not health_component.is_alive():
		# 		state = animation_states.DIE
		# animation_states.DIE:
		# 	player_sprite.play("die")

func _process(delta):
	handle_states()
	#Test taking damage
	if Input.is_action_just_pressed("take_damage"):
		health_component.take_damage(25)
	
	#Handle jump input
	if Input.is_action_just_pressed("jump") and (is_on_floor() or off_edge_timer < 0.6):
		velocity.y = jump

func _input(event: InputEvent) -> void:
	#Handle run input
	if event.is_action_pressed("run"):
		running = not running
		state = animation_states.RUN
		if running:
			player_sprite.play("run")
		else:
			player_sprite.play("walk")
	elif event.is_action_released("run"):
		running = false
		state = animation_states.WALK if velocity.x != 0 else animation_states.IDLE
		player_sprite.play("walk" if not is_on_floor() else "idle")

func _physics_process(delta: float) -> void:
	#Drop down through one-way platforms
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
	
	var max_speed = run_max_speed if running else walk_max_speed
	var move_speed = run_speed if running else walk_speed
	
	# Get the input direction and handle the movement/deceleration. 
	direction = Input.get_axis("move_left", "move_right") * max_speed
	if direction != 0:
		is_facing_right = direction > 0
		player_sprite.scale.x = -1 * abs(player_sprite.scale.x) if not is_facing_right else abs(player_sprite.scale.x)
		velocity.x = move_toward(velocity.x, direction, move_speed * acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, direction, deceleration * delta)

	# Your movement logic...

	move_and_slide()

func on_death():
	# Handle player death logic here
	print("Player has died.")
	if respawn_point:
		global_position = respawn_point.global_position
		velocity = Vector2.ZERO
		health_component.heal(health_component.get_max_health())  # Reset health on respawn
		print("Player respawned at: ", respawn_point.global_position)
	else:
		print("No respawn point set, player will not respawn.")
	

func on_ladder_entered():
	# Handle logic when the player enters a ladder
	print("Player entered ladder.")
