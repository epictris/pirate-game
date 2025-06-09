extends Node

@export var health: int = 100
@export var max_health: int = 100
var health_component : health_class
signal health_changed

func _ready():
	# Initialize the health component
	health_component = health_class.new(health, max_health)
	health_component.set_parent(get_parent())

func take_damage(amount: int):
	health_component.take_damage(amount)
	health_changed.emit()

func heal(amount: int):
	health_component.heal(amount)
	health_changed.emit()

func get_current_health() -> int:
	return health_component.health

func get_max_health() -> int:
	return health_component.max_health
