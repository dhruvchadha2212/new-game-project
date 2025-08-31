extends Node

@export var cube_container: Node
@export var wire_container: Node
@export var camera: Camera3D

func save_scene_state():
	var save_data = {"servers": [], "wires": [], "camera_transform": null}
	
	var camera_transform_dict = {
		"origin": [camera.global_transform.origin.x, camera.global_transform.origin.y, camera.global_transform.origin.z],
		"basis_x": [camera.global_transform.basis.x.x, camera.global_transform.basis.x.y, camera.global_transform.basis.x.z],
		"basis_y": [camera.global_transform.basis.y.x, camera.global_transform.basis.y.y, camera.global_transform.basis.y.z],
		"basis_z": [camera.global_transform.basis.z.x, camera.global_transform.basis.z.y, camera.global_transform.basis.z.z],
	}
	save_data.camera_transform = camera_transform_dict

	# Save all cubes
	for cube in cube_container.get_children():
		save_data["servers"].append({
			"id": cube.node_id,
			"type": Globals.ServerType.keys()[cube.type],
			"position": [cube.global_position.x, cube.global_position.y, cube.global_position.z]
		})

	# Save all wires
	for wire in wire_container.get_children():
		save_data["wires"].append({
			"start_id": wire.start_node.node_id,
			"end_id": wire.end_node.node_id
		})

	# Save to disk as JSON
	var file = FileAccess.open(Globals.save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("Scene saved to", Globals.save_path)
