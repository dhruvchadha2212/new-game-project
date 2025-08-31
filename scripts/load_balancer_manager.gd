extends "res://scripts/base_server_manager.gd"

@export var load_balancer_scene: PackedScene

func spawn_server(camera: Camera3D, node_id: String = "-1", position: Vector3 = Vector3.ZERO):
	if node_id == "-1":
		node_id = str(Time.get_ticks_usec())
	var new_load_balancer = load_balancer_scene.instantiate()
	new_load_balancer.camera = camera
	new_load_balancer.node_id = node_id
	cube_container.add_child(new_load_balancer)
	new_load_balancer.global_position = position
	print("Spawned new Load Balancer with ID:", new_load_balancer.node_id)
	return new_load_balancer

func on_request_packet_reached(request_packet, packet_start_node, packet_end_node):
	var start_node = packet_end_node
	var valid_end_nodes = []
	
	for wire in start_node.connected_wires:
		var end_node = null
		if wire.start_node == start_node:
			end_node = wire.end_node
		elif wire.end_node == start_node:
			end_node = wire.start_node
		else:
			push_error("Wire does not connect to this cube.")
			continue
		
		if end_node != packet_start_node:
			valid_end_nodes.append(end_node)
	print(valid_end_nodes)
	if valid_end_nodes.size() == 0:
		return

	var random_index = randi() % valid_end_nodes.size()
	var end_node = valid_end_nodes[random_index]
	var packet = packet_manager.spawn_new_request_packet(start_node, end_node)
	packet.packet_reached.connect(
		manager_handler.get_manager_for_server_type(end_node.type).on_request_packet_reached)
	packet.send()

func on_response_packet_reached(response_packet, start_node, end_node):
	print("response received")
