extends Node

@export var packet_scene: PackedScene
@export var packet_container: Node

func send_packets_from_cube(cube):
	# Safety check
	if cube == null:
		push_error("send_packets_from_cube called with null cube")
		return
	
	# Send a packet to each cube connected by wires to this cube
	for wire in cube.connected_wires:
		var target_cube = null
		if wire.start_cube == cube:
			target_cube = wire.end_cube
		elif wire.end_cube == cube:
			target_cube = wire.start_cube
		else:
			# Wire does not connect to this cube (should not happen)
			continue
		
		# Instantiate and setup packet
		var packet = packet_scene.instantiate()
		packet_container.add_child(packet)
		packet.start_packet(cube, target_cube)
