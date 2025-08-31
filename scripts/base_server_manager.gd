extends Node

@export var packet_factory: Node
@export var mappings: Node

func send_packets_from(start_server):
	for wire in start_server.connected_wires:
		var end_server = null
		if wire.start_server == start_server:
			end_server = wire.end_server
		elif wire.end_server == start_server:
			end_server = wire.start_server
		else:
			push_error("Wire does not connect to this server.")
			continue
		var connection = Connection.new(start_server, end_server)
		var request_packet = packet_factory.spawn_new_packet(
			Globals.PacketType.REQUEST, start_server, end_server, connection)
		request_packet.packet_reached.connect(
			mappings.get_manager_for_server_type(end_server.type).on_request_packet_reached)
		request_packet.send()

func on_request_packet_reached(packet, start_server, end_server):
	push_error("Abstract method 'process_request' must be implemented by subclass")
