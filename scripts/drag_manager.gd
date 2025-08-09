extends Node3D

@onready var camera: Camera3D = %Camera3D

var dragged_object: Node = null

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var mouse_pos = get_viewport().get_mouse_position()
			var origin = camera.project_ray_origin(mouse_pos)
			var end = origin + camera.project_ray_normal(mouse_pos) * 1000

			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(origin, end)
			var result = space_state.intersect_ray(query)
			if result and result.collider:
				dragged_object = result.collider
				dragged_object.on_drag_start()
		else:
			if dragged_object:
				dragged_object.on_drag_end()
				dragged_object = null
