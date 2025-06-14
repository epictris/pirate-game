@tool
extends ColorRect

func _ready():
    # Set initial shader parameters
    update_shader_parameters()

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
        # Add any other shader parameters you want to update
        # material.set_shader_parameter("rect_position", global_position)

# If you want to force updates when other properties change
func _validate_property(property):
    # This is called when any property is modified in the editor
    if property.name in ["material", "size"]:
        # Defer the call to avoid issues during property validation
        call_deferred("update_shader_parameters")
