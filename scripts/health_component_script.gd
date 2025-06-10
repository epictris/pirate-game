extends Node

@export var health: int = 100
@export var max_health: int = 100
var health_component : health_class
signal health_changed
@onready var parent = get_parent()

func _ready():
	if health < 0:
		health = 0
		health_changed.emit()
		die()
	elif health > max_health:
		health = max_health

func take_damage(amount: int):
	health -= amount
	health_changed.emit()
	if health <= 0:
		health = 0
		die()

func heal(amount: int):
	health += amount
	health_changed.emit()
	if health > max_health:
		health = max_health
	health_changed.emit()

func get_current_health() -> int:
	return health

func get_max_health() -> int:
	return max_health

func set_parent(new_parent):
	parent = new_parent

func is_alive() -> bool:
	return health > 0

func die():
	if parent and parent.has_method("on_death"):
		parent.on_death()
