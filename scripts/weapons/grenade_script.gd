extends RigidBody2D

@export var explosion_radius := 50.0
@export var fuse := 1.0
@export var damage := 10.0
@export var explosion : PackedScene = null
var speed := 0.0
var fizzed := false

func _ready():
	load(explosion.resource_path)

func setup(rad,fus,dmg):
	explosion_radius = rad
	fuse = fus
	damage = dmg
	create_bomb()

func create_bomb():
	var explosion_instance = explosion.instantiate()
	explosion_instance.setup(explosion_radius,damage,fuse)
	add_child(explosion_instance)
	explosion_instance.exploded.connect(expire)
	explosion_instance.fizzed.connect(fizz)

func expire():
	queue_free()

func fizz():
	fizzed = true

func take_damage(dmg, body = null):
	if fizzed:
		var explosion_instance = explosion.instantiate()
		explosion_instance.setup(explosion_radius,damage,0.1)
		add_child(explosion_instance)
		explosion_instance.exploded.connect(expire)
