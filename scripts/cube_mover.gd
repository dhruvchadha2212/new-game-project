extends CSGCombiner3D

var camera: Camera3D

var dragging = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Check if the mouse is over this cube
			if _is_mouse_over():
				dragging = true
		else:
			# Mouse button released
			dragging = false

func _process(delta):
	if dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var dir = camera.project_ray_normal(mouse_pos)

		if dir.y != 0:
			var t = -from.y / dir.y
			var intersection = from + dir * t

			# Snap to 1 meter grid
			var snapped_pos = Vector3(
				round(intersection.x),
				0,
				round(intersection.z)
			)
			global_position = snapped_pos

func _is_mouse_over() -> bool:
	var mouse_pos = get_viewport().get_mouse_position()
	var space_state = get_world_3d().direct_space_state

# Define ray start and end points
	var origin = camera.project_ray_origin(mouse_pos)
	var end = origin + camera.project_ray_normal(mouse_pos) * 1000  # 1000 is the ray length

	# Create query parameters instance
	var query = PhysicsRayQueryParameters3D.create(origin, end)

	# Optional: exclude self or other objects
	# query.exclude = [self]

	# Optional: set collision mask if needed
	# query.collision_mask = 1

	# Perform the raycast
	var result = space_state.intersect_ray(query)

	# Check if we hit this cube
	return result and result.collider == self
