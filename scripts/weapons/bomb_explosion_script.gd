extends Area2D

var bomb_radius := 20.0
var bomb_damage := 100.0
var shape = CircleShape2D.new()
var has_expoded := false
var fuse := 5.0
@onready var fuse_timer : Timer = $fuse_timer
var can_explode := false
@export var collision_shape : CollisionShape2D = null
signal exploded
signal fizzed

func explode():
	var explosion_center = global_position

	# Wait one frame to ensure area updates
	await get_tree().process_frame

	var areas = get_overlapping_areas()
	for area in areas:
		if not area.has_method("take_damage"):
			continue

		# Create ray from explosion to body
		var ray = RayCast2D.new()
		ray.global_position = explosion_center
		ray.target_position = area.global_position - explosion_center
		ray.collision_mask = (1 << 0) | (1 << 5) #check layers 1 and 6 (walls and shields)
		ray.enabled = true
		ray.exclude_parent = true
		add_child(ray)
		ray.force_raycast_update()
		print(ray.is_colliding())
		if ray.is_colliding():
			var collider = ray.get_collider()
			print(collider)
			if collider == area:
				area.take_damage(bomb_damage,self)
		else:
			# print(area)
			area.take_damage(bomb_damage,self)  # No collision, apply damage

		ray.queue_free()
	exploded.emit()
	expire()

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
			explode()
			has_expoded = true

func expire():
	queue_free()

func _on_fuse_timer_timeout() -> void:
	print("exploding!")
	can_explode = true
