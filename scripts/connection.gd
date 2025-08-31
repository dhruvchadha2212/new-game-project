extends Resource

class_name Connection

var id: String
var start_server: Node
var end_server: Node

func _init(start_server, end_server):
	self.id = _initialize_connection_id(start_server, end_server)
	self.start_server = start_server
	self.end_server = end_server

func _initialize_connection_id(start_server, end_server):
	var host_0_port_0 = start_server.id + str(randi() % 65536)
	var host_1_port_1 = end_server.id + str(randi() % 65536)
	return "connection_" + host_0_port_0 + "_"+ host_1_port_1
