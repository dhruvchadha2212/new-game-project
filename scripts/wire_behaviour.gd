extends StaticBody3D

var start_server: Node = null
var end_server: Node = null
var camera: Camera3D
var dragging = false

var mesh_instance: MeshInstance3D = null

func fix_wire_start(server: Node, cam: Camera3D):
	start_server = server
	camera = cam
	dragging = true

func _process(_delta):
	if dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		var origin = camera.project_ray_origin(mouse_pos)
		var direction = camera.project_ray_normal(mouse_pos)
		var end_pos: Vector3
		if direction.y != 0:
			# Ray-plane intersection with ground (Y=0)
			var t = -origin.y / direction.y
			end_pos = origin + direction * t
		else:
			# Fallback: straight in front of camera if ray is parallel
			end_pos = origin + direction * 5.0
		update_cylinder(start_server.global_position, end_pos)

func fix_wire_end(server: Node):
	end_server = server
	dragging = false
	update_cylinder(start_server.global_position, end_server.global_position)
	start_server.add_wire(self)
	end_server.add_wire(self)

func update_cylinder(start_pos: Vector3, end_pos: Vector3):
	var mid_point = (start_pos + end_pos) * 0.5
	global_position = mid_point

	var direction = end_pos - start_pos
	var length = direction.length()

	# Scale the cylinder along Y to match length/2 (half-length because cylinder extends +/- along Y)
	scale = Vector3(0.05, length / 2.0, 0.05)

	var from_dir = Vector3.UP
	var to_dir = direction.normalized()
	var dot = from_dir.dot(to_dir)

	var quat: Quaternion

	if dot > 0.9999:
		# Directions are basically the same, no rotation needed
		quat = Quaternion()  # identity quaternion
	elif dot < -0.9999:
		# Directions are opposite, rotate 180 degrees around any perpendicular axis (e.g., X axis)
		quat = Quaternion(Vector3(1, 0, 0), PI)
	else:
		var rotation_axis = from_dir.cross(to_dir)
		var axis_length = rotation_axis.length()
		var angle = acos(dot)
		if axis_length < 0.0001:
			# Fallback: choose any perpendicular axis (e.g., X axis)
			rotation_axis = Vector3(1, 0, 0)
		else:
			rotation_axis = rotation_axis / axis_length
		quat = Quaternion(rotation_axis, angle)
	global_rotation = quat.get_euler()
