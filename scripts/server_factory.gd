extends Node

@export var server_container: Node
@export var service_scene: PackedScene
@export var load_balancer_scene: PackedScene
@export var client_scene: PackedScene

func spawn_server(server_type: Globals.ServerType, camera: Camera3D, id: String = "-1", position: Vector3 = Vector3.ZERO):
	var new_server = get_server_scene_from_server_type(server_type).instantiate()
	if id == "-1":
		id = str(Time.get_ticks_usec())
	new_server.id = id
	new_server.camera = camera
	server_container.add_child(new_server)
	new_server.global_position = position
	print("Spawned new server with ID:", new_server.id)
	return new_server

func get_server_scene_from_server_type(server_type):
	match server_type:
		Globals.ServerType.SERVICE:
			return service_scene
		Globals.ServerType.LOAD_BALANCER:
			return load_balancer_scene
		Globals.ServerType.CLIENT:
			return client_scene
