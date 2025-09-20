extends Node

## Responsible for instantiating and initialising a new packet_scene 
## and calling its send_packet function

@export var packet_container: Node
@export var packet_scene: PackedScene

@export var request_packet_material: StandardMaterial3D
@export var response_packet_material: StandardMaterial3D

func spawn_new_packet(
	protocol: Globals.Protocol, 
	packet_type: Globals.PacketType, 
	start_server: Node, 
	end_server: Node, 
	connection: Connection,
	correlation_id: String):
		var packet = packet_scene.instantiate()
		packet.id = _initialize_packet_id();
		packet.start_server = start_server
		packet.end_server = end_server
		packet.connection = connection
		packet.protocol = protocol
		packet.type = packet_type
		packet.correlation_id = correlation_id
		packet_container.add_child(packet)
		packet.get_node("MeshInstance3D").material_override = _get_material(packet_type)
		return packet

func _initialize_packet_id():
	var base_id = Time.get_ticks_usec()
	var random_suffix = randi() % 10000
	return "packet_" + str(base_id) + "_" + str(random_suffix)

func _get_material(packet_type):
	match packet_type:
		Globals.PacketType.REQUEST:
			return request_packet_material
		Globals.PacketType.RESPONSE:
			return response_packet_material
