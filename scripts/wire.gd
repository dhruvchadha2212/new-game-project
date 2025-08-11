extends Node3D

var start_cube: Node = null
var end_cube: Node = null
var camera: Camera3D
var placing = false

var mesh_instance: MeshInstance3D = null

func _ready():
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = CylinderMesh.new()
	add_child(mesh_instance)

func start_wire(cube: Node, cam: Camera3D):
	start_cube = cube
	camera = cam
	placing = true

func _process(delta):
	if placing:
		var mouse_pos = get_viewport().get_mouse_position()
		var origin = camera.project_ray_origin(mouse_pos)
		var direction = camera.project_ray_normal(mouse_pos)
		var end_pos = origin + direction * 5.0  # adjust depth as needed
		update_cylinder(start_cube.global_position, end_pos)

func finalize_wire(cube: Node):
	end_cube = cube
	placing = false
	update_cylinder(start_cube.global_position, end_cube.global_position)

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
		var rotation_axis = from_dir.cross(to_dir).normalized()
		var angle = acos(dot)
		quat = Quaternion(rotation_axis, angle)

	global_rotation = quat.get_euler()
