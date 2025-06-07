extends Node3D

@export var top_left: Marker3D
@export var top_right: Marker3D
@export var bottom_left: Marker3D
@export var bottom_right: Marker3D


func create_sail_from_points() -> MeshInstance3D:
	var array_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	var vertices = PackedVector3Array([
		top_left.position, top_right.position, bottom_left.position, 
		bottom_left.position, top_right.position, bottom_right.position,
		
		top_left.position, bottom_left.position, top_right.position, 
		bottom_left.position, bottom_right.position, top_right.position
	])

	arrays[0] = vertices

	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = array_mesh
	
	return mesh_instance

func _ready() -> void:
	var sail = create_sail_from_points()
	add_child(sail)

	
	
	
	
