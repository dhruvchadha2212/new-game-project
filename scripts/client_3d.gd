extends "res://scripts/base_server_3d.gd"

func _init():
	self.type = Globals.ServerType.CLIENT

func send_initial_request():
	# This function is for clients to start a new request chain.
	if connected_wires.is_empty():
		print("Client has no connections to send a request.")
		return

	# For simplicity, send to the first connected wire.
	var wire = connected_wires[0]
	var end_server = wire.end_server if wire.start_server == self else wire.start_server
	
	var connection = Connection.new(self, end_server)
	var correlation_id = str(Time.get_ticks_msec()) + "_" + str(randi() % 1000)

	var request_packet = packet_factory.spawn_new_packet(
		Globals.Protocol.HTTP,
		Globals.PacketType.REQUEST,
		self,
		end_server,
		connection,
		correlation_id)
	
	request_packet.packet_reached.connect(end_server.handle_packet)
	request_packet.send()

func handle_response(response_packet):
	print("Client '", id, "' received a final response for correlation ID: ", response_packet.correlation_id)
