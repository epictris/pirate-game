@tool
extends ColorRect

@export var position_3d: Vector3
@export var width_3d: float
@export var height_3d: float
@export var right_vector_3d: Vector3

func _ready():
	# Set initial shader parameters
	size.x = width_3d * 300
	size.y = height_3d * 300
	position.x = size.x * 0.5
	position.y = -position_3d.y * 300 - size.y * 0.5
	update_shader_parameters()

func _process(_delta: float) -> void:
	size.x = width_3d * 300
	size.y = height_3d * 300
	position.x = -size.x * 0.5
	position.y = -position_3d.y * 300 - size.y * 0.5
	update_shader_parameters()

func set_position_3d(value: Vector3):
	position_3d = value

func set_right_direction_3d(value: Vector3):
	right_vector_3d = value

func _notification(what):
	# This catches various events including property changes
	match what:
		NOTIFICATION_RESIZED:
			# Called when the ColorRect is resized
			update_shader_parameters()
		NOTIFICATION_TRANSFORM_CHANGED:
			# Called when position changes
			update_shader_parameters()

func update_shader_parameters():
	# Only update if we have a material with a shader
	if material and material is ShaderMaterial:
		material.set_shader_parameter("rect_size", size)
		material.set_shader_parameter("world_position", position_3d)
		material.set_shader_parameter("cross_section_direction", right_vector_3d)
		# Add any other shader parameters you want to update
		# material.set_shader_parameter("rect_position", global_position)

# If you want to force updates when other properties change
func _validate_property(property):
	# This is called when any property is modified in the editor
	if property.name in ["material", "size"]:
		# Defer the call to avoid issues during property validation
		call_deferred("update_shader_parameters")
