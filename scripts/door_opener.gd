extends Area2D

func _input(event):
	if event.is_action_pressed("toggle_door"):
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if body.has_method("toggle_door"):
				print("dooor")
				body.toggle_door()