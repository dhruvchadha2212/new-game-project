extends Node

@export var server_container: Node
@export var service_scene: PackedScene
@export var load_balancer_scene: PackedScene

func spawn_server(server_type: Globals.ServerType, camera: Camera3D, node_id: String = "-1", position: Vector3 = Vector3.ZERO):
	if node_id == "-1":
		node_id = str(Time.get_ticks_usec())
	var new_server = get_server_scene_from_server_type(server_type).instantiate()
	new_server.camera = camera
	new_server.node_id = node_id
	new_server.global_position = position
	server_container.add_child(new_server)
	print("Spawned new server with ID:", new_server.node_id)
	return new_server

func get_server_scene_from_server_type(server_type):
	match server_type:
		Globals.ServerType.SERVICE:
			return service_scene
		Globals.ServerType.LOAD_BALANCER:
			return load_balancer_scene
