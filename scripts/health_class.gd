class_name health_class

@export var health: int = 100
@export var max_health: int = 100
var parent

func _init(initial_health, initial_max_health):
	# Ensure health is initialized correctly
	health = initial_health
	max_health = initial_max_health
	if health < 0:
		health = 0
	elif health > max_health:
		health = max_health

func set_parent(new_parent):
	parent = new_parent

func take_damage(amount: int):
	health -= amount
	if health < 0:
		health = 0
		die()

func heal(amount: int):
	health += amount
	if health > max_health:
		health = max_health

func is_alive() -> bool:
	return health > 0

func die():
	if parent & parent.has_method("on_death"):
		parent.on_death()
			