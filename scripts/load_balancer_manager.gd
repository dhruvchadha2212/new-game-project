extends "res://scripts/base_server_manager.gd"

@export var load_balancer_scene: PackedScene

var connection_relay_mapping = {} # forward connection to previous connection

func on_request_packet_reached(request_packet, start_server, end_server):
	var new_start_server = end_server
	var valid_new_end_servers = []
	
	for wire in end_server.connected_wires:
		var new_end_server = null
		if wire.start_server == end_server:
			new_end_server = wire.end_server
		elif wire.end_server == end_server:
			new_end_server = wire.start_server
		else:
			push_error("Wire does not connect to this server.")
			continue
		
		if new_end_server != start_server:
			valid_new_end_servers.append(new_end_server)
	if valid_new_end_servers.size() == 0:
		return

	var random_index = randi() % valid_new_end_servers.size()
	var new_end_server = valid_new_end_servers[random_index]
	var connection = Connection.new(new_start_server, new_end_server)
	var packet = packet_factory.spawn_new_packet(
		Globals.PacketType.REQUEST, new_start_server, new_end_server, connection)
	connection_relay_mapping[packet.connection] = request_packet.connection
	packet.packet_reached.connect(
		mappings.get_manager_for_server_type(new_end_server.type).on_request_packet_reached)
	packet.send()

func on_response_packet_reached(response_packet, start_server, end_server):
	var previous_connection = connection_relay_mapping[response_packet.connection]
	var new_start_server = end_server
	var new_end_server = previous_connection.start_server
	var packet = packet_factory.spawn_new_packet(
		Globals.PacketType.RESPONSE, new_start_server, new_end_server, previous_connection)
	packet.packet_reached.connect(
		mappings.get_manager_for_server_type(new_end_server.type).on_response_packet_reached)
	packet.send()
