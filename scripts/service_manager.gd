extends "res://scripts/base_server_manager.gd"

@export var service_scene: PackedScene

func spawn_server(camera: Camera3D, node_id: String = "-1", position: Vector3 = Vector3.ZERO):
	if node_id == "-1":
		node_id = str(Time.get_ticks_usec())
	var new_service = service_scene.instantiate()
	new_service.camera = camera
	new_service.node_id = node_id
	cube_container.add_child(new_service)
	new_service.global_position = position
	print("Spawned new Service with ID:", new_service.node_id)
	return new_service

func on_request_packet_reached(request_packet, start_node, end_node):
	return
	var response_time_ms = 1 + randi() % 1000
	await get_tree().create_timer(response_time_ms / 1000.0).timeout
	var new_start_node = end_node
	var new_end_node = start_node
	var response_packet = packet_manager.spawn_new_response_packet(new_start_node, new_end_node)
	response_packet.packet_reached.connect(
		manager_handler.get_manager_for_server_type(end_node.type).on_response_packet_reached)
	response_packet.send()

func on_response_packet_reached(response_packet, start_node, end_node):
	print("response received")
