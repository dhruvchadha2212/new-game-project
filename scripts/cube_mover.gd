extends StaticBody3D

var camera: Camera3D

var dragging = false

func on_drag_start():
	dragging = true

func on_drag_end():
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
