extends CharacterBody2D

enum Layers{
	LEVEL = 0b0001,
	FALLTHROUGH = 0b0010,
	LADDERS = 0b0100,
	PROJECTILES = 0b0101,
}

enum animation_states {
	IDLE,
	WALK,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	DAMAGE,
	DIE,
	CLIMB
}

var collision_mask_default := collision_mask

var collision_mask_fallthrough = collision_mask & ~Layers.FALLTHROUGH

var collision_mask_no_projectiles = collision_mask & ~Layers.PROJECTILES

@onready var health_component: Node = $health_component
@onready var player: CharacterBody2D = $"."
@onready var weapon_point: Node2D = $weapon_point
@onready var player_sprite: AnimatedSprite2D = $player_sprite
@onready var ladder_collider: Area2D = $ladder_collider
@onready var weapons : Node2D = $weapon_point

@export var respawn_point: Node2D = null
const gravity = 2500
const term_velocity = 10000
var is_facing_right = true
var is_attacking = false
var respawn_timer := 0.0
var state = animation_states.IDLE
var on_ladder := false
var can_climb := false
var ship_rotation := 0.0
var has_weapon := false
var selected_weapon := 0

func _ready():
	collision_mask_default = collision_mask
	collision_mask_fallthrough = collision_mask & ~Layers.FALLTHROUGH
	if weapon_point.get_child_count()>0:
		has_weapon = true
		for weapon in weapon_point.get_children():
			weapon.visible = false
		weapon_point.get_child(selected_weapon).visible = true

func handle_states():
	match state:
		animation_states.IDLE:
			player_sprite.play("idle")
			if velocity.x != 0:
				state = animation_states.WALK
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
		animation_states.CLIMB:
			if not on_ladder:
				state = animation_states.IDLE
				player_sprite.play("idle")
			else:
				player_sprite.play("climb")
		animation_states.RUN:
			if velocity.x == 0:
				player_sprite.play("idle")
			elif is_on_floor():
				player_sprite.play("run")

func _input(event):
	if has_weapon:
		if event.is_action_pressed("previous_weapon"):
			weapon_point.get_child(selected_weapon).visible = false
			selected_weapon = selected_weapon - 1 if selected_weapon > 0 else weapon_point.get_child_count() - 1
			print(selected_weapon)
			weapon_point.get_child(selected_weapon).visible = true

		if event.is_action_pressed("next_weapon"):
			weapon_point.get_child(selected_weapon).visible = false
			selected_weapon = selected_weapon + 1 if selected_weapon < weapon_point.get_child_count() - 1 else 0
			print(selected_weapon)
			weapon_point.get_child(selected_weapon).visible = true

		if event.is_action_pressed("attack"):
			var weapon = weapon_point.get_child(selected_weapon)
			if weapon.has_method("attack"):
				weapon.attack()
			elif weapon.has_method("dir_attack"):
				weapon.dir_attack(is_facing_right)

func _process(delta):
	handle_states()
	#Test taking damage
	if Input.is_action_just_pressed("take_damage"):
		player_sprite.play("damage")
		health_component.take_damage(25)
	player_sprite.scale.x = -(abs(player_sprite.scale.x)) if not is_facing_right else abs(player_sprite.scale.x)

func _physics_process(delta: float) -> void:
	# Drop down through one-way platforms
	if Input.is_action_pressed("drop_down"):
		#if we're holding down, apply the collision mask to not collide with the one-way platforms
		collision_mask = collision_mask_fallthrough
	else:
		#make sure we are colliding with them otherwise
		collision_mask = collision_mask_default

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
	

func _on_ladder_collider_body_entered(body: Node2D) -> void:
	can_climb = true

func _on_ladder_collider_body_exited(body: Node2D) -> void:
	can_climb = false
	on_ladder = false

func dodge_projectiles(is_on):
	collision_mask = collision_mask_no_projectiles if is_on else collision_mask_default
