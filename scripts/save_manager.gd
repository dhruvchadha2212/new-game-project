extends Node

@export var server_container: Node
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

	# Save all servers
	for server in server_container.get_children():
		save_data["servers"].append({
			"id": server.id,
			"type": Globals.ServerType.keys()[server.type],
			"position": [server.global_position.x, server.global_position.y, server.global_position.z]
		})

	# Save all wires
	for wire in wire_container.get_children():
		save_data["wires"].append({
			"start_id": wire.start_server.id,
			"end_id": wire.end_server.id
		})

	# Save to disk as JSON
	var file = FileAccess.open(Globals.save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("Scene saved to", Globals.save_path)

func save_architecture_state():
	var current_architecture = {"servers": {}}
	if FileAccess.file_exists(Globals.architecture_path):
		var file = FileAccess.open(Globals.architecture_path, FileAccess.READ)
		var content = JSON.parse_string(file.get_as_text())
		if content and typeof(content) == TYPE_DICTIONARY:
			current_architecture = content
		file.close()

	var new_architecture = {"servers": {}}
	
	# Process servers currently in the scene
	for server in server_container.get_children():
		var server_id = server.id
		var server_data = {}
		
		if current_architecture.servers.has(server_id):
			# Preserve existing architecture if it exists
			server_data = current_architecture.servers[server_id]
		else:
			server_data["upstream_server_ids"] = []
			server_data["type"] = Globals.ServerType.keys()[server.type]
		
		new_architecture.servers[server_id] = server_data

	var file_write = FileAccess.open(Globals.architecture_path, FileAccess.WRITE)
	file_write.store_string(JSON.stringify(new_architecture, "\t"))
	file_write.close()
	print("Architecture saved to ", Globals.architecture_path)
