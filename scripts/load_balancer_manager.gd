extends "res://scripts/base_server_manager.gd"

@export var load_balancer_scene: PackedScene

var connection_relay_mapping = {} # forward connection to previous connection

func on_request_packet_received(request_packet):
	var valid_end_servers = []
	for wire in request_packet.end_server.connected_wires:
		var valid_end_server = null
		if wire.start_server == request_packet.end_server:
			valid_end_server = wire.end_server
		elif wire.end_server == request_packet.end_server:
			valid_end_server = wire.start_server
		else:
			push_error("Wire does not connect to this server.")
			continue
		if valid_end_server != request_packet.start_server:
			valid_end_servers.append(valid_end_server)

	if valid_end_servers.size() == 0:
		return
	var random_index = randi() % valid_end_servers.size()
	var end_server = valid_end_servers[random_index]
	var start_server = request_packet.end_server
	var connection = Connection.new(start_server, end_server)
	var packet = packet_factory.spawn_new_packet(
		Globals.Protocol.HTTP, 
		Globals.PacketType.REQUEST, 
		start_server, 
		end_server, 
		connection)
	connection_relay_mapping[packet.connection] = request_packet.connection
	packet.packet_reached.connect(
		mappings.get_manager_for_server_type(end_server.type).on_request_packet_received)
	packet.send()

func on_response_packet_received(response_packet):
	var previous_connection = connection_relay_mapping[response_packet.connection]
	var start_server = previous_connection.end_server
	var end_server = previous_connection.start_server
	var packet = packet_factory.spawn_new_packet(
		Globals.Protocol.HTTP,
		Globals.PacketType.RESPONSE,
		start_server, 
		end_server, 
		previous_connection)
	packet.packet_reached.connect(
		mappings.get_manager_for_server_type(end_server.type).on_response_packet_received)
	packet.send()
