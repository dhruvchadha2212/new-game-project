extends "res://scripts/base_server_3d.gd"

func _init():
	self.type = Globals.ServerType.SERVICE

func handle_request(request_packet):
	var workflow = ServiceRequestWorkflow.new(_get_upstream_server_ids())
	workflow.set_original_request_packet(request_packet)
	pending_workflows[request_packet.correlation_id] = workflow
	_process_workflow_step(workflow)

func handle_response(response_packet):
	var correlation_id = response_packet.correlation_id
	if pending_workflows.has(correlation_id):
		var workflow = pending_workflows[correlation_id]
		workflow.advance_to_next_upstream()
		_process_workflow_step(workflow)

func _send_response(request_packet):
	var start_server = request_packet.end_server
	var end_server = request_packet.start_server
	var response_packet = packet_factory.spawn_new_packet(
		Globals.Protocol.HTTP,
		Globals.PacketType.RESPONSE, 
		start_server,
		end_server, 
		request_packet.connection,
		request_packet.correlation_id)
	response_packet.packet_reached.connect(end_server.handle_packet)
	response_packet.send()

func _process_workflow_step(workflow: ServiceRequestWorkflow):
	var original_request_packet = workflow.original_request_packet
	if workflow.is_complete():
		_send_response(original_request_packet)
		pending_workflows.erase(original_request_packet.correlation_id)
		return
	var next_upstream_id = workflow.get_next_upstream_id()
	var next_upstream_server = _find_server_by_id(next_upstream_id)
	
	if not next_upstream_server:
		printerr("upstream server not found: ", next_upstream_id)
		return
	var start_server = original_request_packet.end_server
	var connection = Connection.new(start_server, next_upstream_server)
	var upstream_packet = packet_factory.spawn_new_packet(
		Globals.Protocol.HTTP, 
		Globals.PacketType.REQUEST,
		start_server, 
		next_upstream_server, 
		connection, 
		original_request_packet.correlation_id)
		
	upstream_packet.packet_reached.connect(next_upstream_server.handle_packet)
	upstream_packet.send()
