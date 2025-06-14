extends Node

var current_2d_scene: Node2D = null

func get_current_2d_scene() -> Node2D:
	if current_2d_scene:
		return current_2d_scene
	else:
		print("No current 2D scene set.")
		return null

func set_current_2d_scene(scene: Node2D):
	if scene and scene is Node2D:
		current_2d_scene = scene
		print("Current 2D scene set to: ", scene.name)
	else:
		print("Invalid scene provided. Must be a Node2D instance.")