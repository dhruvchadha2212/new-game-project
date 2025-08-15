extends Node

@export var cube_container: Node
@export var wire_container: Node
@export var cube_scene: PackedScene
@export var wire_scene: PackedScene
@export var camera: Camera3D
@export var cube_spawner: Node

func load_scene_state():
	if not FileAccess.file_exists(Globals.save_path):
		print("No save file found!")
		return

	# Read file
	var file = FileAccess.open(Globals.save_path, FileAccess.READ)
	var save_data = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(save_data) != TYPE_DICTIONARY:
		print("Invalid save file")
		return

	# Clear old objects
	for c in cube_container.get_children():
		c.queue_free()
	for w in wire_container.get_children():
		w.queue_free()

	# Recreate cubes
	var id_to_cube = {}
	for cube_data in save_data["cubes"]:
		var pos_array = cube_data["position"]
		var pos_vector3 = Vector3(pos_array[0], pos_array[1], pos_array[2])
		var cube = cube_spawner.spawn_cube(camera, cube_data["id"], pos_vector3)
		id_to_cube[cube.cube_id] = cube

	# Recreate wires
	for wire_data in save_data["wires"]:
		var wire = wire_scene.instantiate()
		wire_container.add_child(wire)
		var start_cube_id = int(wire_data["start_id"])
		var end_cube_id = int(wire_data["end_id"]) 
		wire.fix_wire_start(id_to_cube[start_cube_id], null) # null since no camera needed after placement
		wire.fix_wire_end(id_to_cube[end_cube_id])

	# Restore camera transform
	var t = save_data["camera_transform"]
	var transform = Transform3D()
	transform.origin = Vector3(t["origin"][0], t["origin"][1], t["origin"][2])
	transform.basis.x = Vector3(t["basis_x"][0], t["basis_x"][1], t["basis_x"][2])
	transform.basis.y = Vector3(t["basis_y"][0], t["basis_y"][1], t["basis_y"][2])
	transform.basis.z = Vector3(t["basis_z"][0], t["basis_z"][1], t["basis_z"][2])
	camera.global_transform = transform
