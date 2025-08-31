extends "res://scripts/base_server_manager.gd"

@export var service_scene: PackedScene

func on_request_packet_reached(request_packet, start_server, end_server):
	var response_time_ms = 1 + randi() % 1000
	await get_tree().create_timer(response_time_ms / 1000.0).timeout
	var new_start_server = end_server
	var new_end_server = start_server
	var response_packet = packet_factory.spawn_new_packet(
		Globals.PacketType.RESPONSE, new_start_server, new_end_server, request_packet.connection)
	response_packet.packet_reached.connect(
		mappings.get_manager_for_server_type(new_end_server.type).on_response_packet_reached)
	response_packet.send()

func on_response_packet_reached(response_packet, start_server, end_server):
	print("response received")
