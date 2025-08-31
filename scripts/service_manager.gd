extends "res://scripts/base_server_manager.gd"

@export var service_scene: PackedScene

func on_request_packet_reached(request_packet, start_node, end_node):
	var response_time_ms = 1 + randi() % 1000
	await get_tree().create_timer(response_time_ms / 1000.0).timeout
	var new_start_node = end_node
	var new_end_node = start_node
	var response_packet = packet_factory.spawn_new_packet(Globals.PacketType.RESPONSE, new_start_node, new_end_node)
	response_packet.packet_reached.connect(
		mappings.get_manager_for_server_type(end_node.type).on_response_packet_reached)
	response_packet.send()

func on_response_packet_reached(response_packet, start_node, end_node):
	print("response received")
