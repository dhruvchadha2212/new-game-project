extends Node

@export var service_manager: Node
@export var load_balancer_manager: Node

func get_manager_for_server(server):
	match server.type:
		Globals.ServerType.SERVICE:
			return service_manager
		Globals.ServerType.LOAD_BALANCER:
			return load_balancer_manager
