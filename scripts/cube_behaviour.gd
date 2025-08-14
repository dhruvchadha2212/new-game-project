extends StaticBody3D

var camera: Camera3D
var dragging = false
var connected_wires = []

func add_wire(wire):
	connected_wires.append(wire)

func on_drag_start():
	dragging = true

func on_drag_end():
	dragging = false

func _process(delta):
	if dragging:
		_move_cube()
		_move_attached_wires()

func _move_cube():
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

func _move_attached_wires():
	for wire in connected_wires:
		wire.update_cylinder(wire.start_cube.global_position, wire.end_cube.global_position) 
