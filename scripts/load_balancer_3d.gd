extends "res://scripts/base_server_3d.gd"

var pending_requests = {} # forward connection to previous connection

func _init():
	self.type = Globals.ServerType.LOAD_BALANCER

func handle_request(request_packet):
	# CASE 1: This is a callback request FROM a service destined FOR a client.
	if pending_requests.has(request_packet.correlation_id) and request_packet.start_server.type == Globals.ServerType.SERVICE:
		_route_callback_to_client(request_packet)
		return

	# CASE 2: This is a new request FROM a client destined FOR a service.
	pending_requests[request_packet.correlation_id] = request_packet
	
	var upstream_server_ids = _get_upstream_server_ids()
	if upstream_server_ids.size() == 0:
		push_error("No upstream servers configured for load balancer " + id)
		return
	var random_index = randi() % upstream_server_ids.size()
	var end_server = _find_server_by_id(upstream_server_ids[random_index])
	var start_server = request_packet.end_server
	var connection = Connection.new(start_server, end_server)
	var packet = packet_factory.spawn_new_packet(
		Globals.Protocol.HTTP, 
		Globals.PacketType.REQUEST, 
		start_server, 
		end_server, 
		connection,
		request_packet.correlation_id)
	packet.packet_reached.connect(end_server.handle_request)
	packet.send()

func handle_response(response_packet):
	var original_request_packet = pending_requests[response_packet.correlation_id]
	var original_client = original_request_packet.start_server

	var connection = Connection.new(self, original_client)
	var ack_packet = packet_factory.spawn_new_packet(
		Globals.Protocol.HTTP,
		Globals.PacketType.RESPONSE,
		self,
		original_client,
		connection,
		response_packet.correlation_id
	)
	ack_packet.packet_reached.connect(original_client.handle_packet)
	ack_packet.send()

func _route_callback_to_client(callback_request_packet):
	var original_request_packet = pending_requests[callback_request_packet.correlation_id]
	var original_client = original_request_packet.start_server

	# The service's request is now being routed to the client as a final RESPONSE.
	# This is where the async "REQUEST" from the service becomes a "RESPONSE" for the client.
	var connection = Connection.new(self, original_client)
	var final_response_packet = packet_factory.spawn_new_packet(
		Globals.Protocol.HTTP,
		Globals.PacketType.REQUEST,
		self,
		original_client,
		connection,
		callback_request_packet.correlation_id
	)
	final_response_packet.packet_reached.connect(original_client.handle_packet)
	final_response_packet.send()

	# The workflow is now complete. Clean up the state.
	pending_requests.erase(callback_request_packet.correlation_id)

func _get_upstream_server_ids():
	var architecture_config = Globals.architecture_config.get("servers", {})
	var server_config = architecture_config.get(id, {})
	return server_config.get("upstream_server_ids", [])
