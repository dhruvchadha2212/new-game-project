extends "res://scripts/base_server_manager.gd"

@export var service_scene: PackedScene

func handle_request(request_packet):
	var workflow = request_packet.end_server.request_workflow
	workflow.set_original_request_packet(request_packet)
	request_packet.end_server.pending_workflows[request_packet.correlation_id] = workflow
	_process_workflow_step(workflow)

func handle_response(response_packet):
	var correlation_id = response_packet.correlation_id
	if response_packet.end_server.pending_workflows.has(correlation_id):
		var workflow = response_packet.end_server.pending_workflows[correlation_id]
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
	response_packet.packet_reached.connect(
		mappings.get_manager_for_server_type(end_server.type).handle_response)
	response_packet.send()

func _process_workflow_step(workflow: RequestWorkflow):
	var original_request_packet = workflow.original_request_packet
	if workflow.is_complete():
		_send_response(original_request_packet)
		original_request_packet.end_server.pending_workflows.erase(original_request_packet.correlation_id)
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
		
	upstream_packet.packet_reached.connect(
		mappings.get_manager_for_server_type(next_upstream_server.type).handle_request)
	upstream_packet.send()

func _find_server_by_id(server_id):
	for server in get_tree().get_nodes_in_group("servers"):
		if server.id == server_id:
			return server
	return null
