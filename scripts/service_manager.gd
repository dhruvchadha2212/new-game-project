extends "res://scripts/base_server_manager.gd"

@export var service_scene: PackedScene

func on_request_packet_received(request_packet):
	_process_request(request_packet)
	_send_response(request_packet)

func on_response_packet_received(_response_packet, _start_server, _end_server):
	print("response received")

func _process_request(request_packet):
	var response_time_ms = 1 + randi() % 1000
	await get_tree().create_timer(response_time_ms / 1000.0).timeout

func _send_response(request_packet):
	var start_server = request_packet.end_server
	var end_server = request_packet.start_server
	var response_packet = packet_factory.spawn_new_packet(
		Globals.Protocol.HTTP,
		Globals.PacketType.RESPONSE, 
		start_server, 
		end_server, 
		request_packet.connection)
	response_packet.packet_reached.connect(
		mappings.get_manager_for_server_type(end_server.type).on_response_packet_received)
	response_packet.send()
