extends Area2D

var bomb_radius := 20.0
var bomb_damage := 10.0
var shape = CircleShape2D.new()
var has_expoded := false
var fuse := 5.0
@onready var fuse_timer : Timer = $fuse_timer
var can_explode := false
@export var collision_shape : CollisionShape2D = null
var targets := []
signal exploded
signal fizzed

func _ready():
	fuse_timer.wait_time = fuse
	fuse_timer.one_shot = true
	fuse_timer.start()

func setup(radius,damage,fuse_set):
	bomb_radius = radius
	bomb_damage = damage
	shape.radius = bomb_radius
	collision_shape.shape = shape
	fuse = fuse_set if randf() > 0.01 else fuse_set/3

func _process(delta):
	if (not has_expoded and can_explode):
		if randf()<0.1:
			fizzed.emit()
			expire()
		else:
			collision_shape.disabled = false
			for body in targets:
				if body.has_method("take_damage"):
					body.take_damage(bomb_damage,self)
			has_expoded = true
			exploded.emit()
			expire()
			# collision_shape.disabled = true

func expire():
	queue_free()

func _on_body_exited(body:Node2D) -> void:
	targets.erase(body)

func _on_body_entered(body:Node2D) -> void:
	targets.append(body)

func _on_area_exited(area:Area2D) -> void:
	targets.erase(area)

func _on_area_entered(area:Area2D) -> void:
	targets.append(area)

func _on_fuse_timer_timeout() -> void:
	print("exploding!")
	can_explode = true
