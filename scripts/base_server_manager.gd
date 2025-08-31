extends Node

## Responsible for instantiating and initialising a new cube_scene, from UI
## as well as load_manager.

@export var packet_factory: Node
@export var mappings: Node

func send_packets_from(start_node):
	for wire in start_node.connected_wires:
		var end_node = null
		if wire.start_node == start_node:
			end_node = wire.end_node
		elif wire.end_node == start_node:
			end_node = wire.start_node
		else:
			push_error("Wire does not connect to this cube.")
			continue
		var request_packet = packet_factory.spawn_new_packet(Globals.PacketType.REQUEST, start_node, end_node)
		request_packet.packet_reached.connect(
			mappings.get_manager_for_server_type(end_node.type).on_request_packet_reached)
		request_packet.send()

func on_request_packet_reached(packet, start_node, end_node):
	push_error("Abstract method 'process_request' must be implemented by subclass")
