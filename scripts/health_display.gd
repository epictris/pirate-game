extends Control

@onready var health_bar: ProgressBar = $health_bar
@export var health_component_path: NodePath
var health_component: Node

func _ready():
	# Ensure the health component is loaded
	if health_component_path:
		health_component = get_node(health_component_path)
		if not health_component.has_method("take_damage") or not health_component.has_method("heal"):
			print("Health component not found at path: ", health_component_path)
			return
		else:
			health_bar.max_value = health_component.get_max_health()
			health_bar.value = health_component.get_current_health()
			health_component.health_changed.connect(_on_health_changed)
	else:
		print("Health component path not set.")
		
func _on_health_changed():
	health_bar.value = health_component.get_current_health()
