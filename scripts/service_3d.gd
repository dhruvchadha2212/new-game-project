extends "res://scripts/base_server_3d.gd"

func _init():
	self.type = Globals.ServerType.SERVICE

func handle_request(request_packet):
	var correlation_id = request_packet.correlation_id
	if not pending_workflows.has(correlation_id):
		pending_workflows[request_packet.correlation_id] = ServiceRequestWorkflow.new(_get_upstream_server_ids(), request_packet)
	var workflow = pending_workflows[request_packet.correlation_id]
	## sending back an ack response
	_create_and_send_packet(
		request_packet.end_server,
		request_packet.start_server,
		request_packet.correlation_id,
		Globals.PacketType.RESPONSE)
	## imagine below method being called in async manner using queues, after the ack response
	_process_workflow(workflow)

func handle_response(response_packet):
	print("Ack received by " + response_packet.end_server.id)

func _process_workflow(workflow: ServiceRequestWorkflow):
	workflow.advance_to_next_upstream()
	var original_request_packet = workflow.original_request_packet
	if workflow.is_complete():
		_create_and_send_packet(
			original_request_packet.end_server,
			original_request_packet.start_server,
			original_request_packet.correlation_id,
			Globals.PacketType.REQUEST)
		pending_workflows.erase(original_request_packet.correlation_id)
		return
	var next_upstream_id = workflow.get_next_upstream_id()
	var next_upstream_server = _find_server_by_id(next_upstream_id)
	
	if not next_upstream_server:
		printerr("upstream server not found: ", next_upstream_id)
		return
	var start_server = original_request_packet.end_server
	_create_and_send_packet(
		start_server, 
		next_upstream_server, 
		original_request_packet.correlation_id, 
		Globals.PacketType.REQUEST)

func _create_and_send_packet(start_server, end_server, correlation_id, packet_type):
	var connection = Connection.new(start_server, end_server)
	var packet = packet_factory.spawn_new_packet(
		Globals.Protocol.HTTP, 
		packet_type,
		start_server, 
		end_server, 
		connection, 
		correlation_id)
	packet.packet_reached.connect(end_server.handle_packet)
	packet.send()

func _get_upstream_server_ids():
	var architecture_config = Globals.architecture_config.get("servers", {})
	var server_config = architecture_config.get(id, {})
	return server_config.get("dependencies", [])
