extends Node

## Responsible for instantiating and initialising a new packet_scene 
## and calling its send_packet function

@export var packet_scene: PackedScene
@export var packet_container: Node

func spawn_new_packet(start_node, end_node):
	var packet = packet_scene.instantiate()
	packet.initialize_id();
	packet.start_node = start_node
	packet.end_node = end_node
	packet_container.add_child(packet)
	return packet
