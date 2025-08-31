extends Node

## Responsible for instantiating and initialising a new packet_scene 
## and calling its send_packet function

@export var packet_container: Node
@export var request_packet_scene: PackedScene
@export var response_packet_scene: PackedScene

func spawn_new_packet(packet_type, start_server, end_server, connection):
	var packet_scene = get_packet_scene_from_packet_type(packet_type)
	var packet = _initialise_new_packet(start_server, end_server, packet_scene, connection)
	packet_container.add_child(packet)
	return packet

func _initialise_new_packet(start_server, end_server, packet_scene, connection: Connection):
	var packet = packet_scene.instantiate()
	packet.id = _initialize_packet_id();
	packet.start_server = start_server
	packet.end_server = end_server
	packet.connection = connection
	return packet

func _initialize_packet_id():
	var base_id = Time.get_ticks_usec()
	var random_suffix = randi() % 10000
	return "packet_" + str(base_id) + "_" + str(random_suffix)

func get_packet_scene_from_packet_type(packet_type):
	match packet_type:
		Globals.PacketType.REQUEST:
			return request_packet_scene
		Globals.PacketType.RESPONSE:
			return response_packet_scene
