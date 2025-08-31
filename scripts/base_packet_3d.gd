extends Node3D

## Responsible for moving an instantiated packet_scene from start node to end node
## and emitting a signal when done.

signal packet_reached(packet, start_server, end_server)

var start_server: Node = null
var end_server: Node = null
var speed: float = 10.0   # meters per second
var percent: float = 0.0 # progress along the wire [0,1]
var id: String
var type: Globals.PacketType
var connection: Connection
var reached = false

# Call this to initialize and begin movement
func send():
	# Check for wire connection
	if are_cubes_connected(start_server, end_server) == null:
		print("Packet cannot travel: no wire between cubes %s and %s" % [str(start_server.cube_id), str(end_server.cube_id)])
		queue_free()
		return
	percent = 0.0
	global_position = start_server.global_position

# Helper to search for wire
func are_cubes_connected(a: Node, b: Node) -> bool:
	for wire_candidate in a.connected_wires:
		if wire_candidate.start_server == a and wire_candidate.end_server == b:
			return true
		elif wire_candidate.start_server == b and wire_candidate.end_server == a:
			return true
	return false

func _process(delta):
	if reached:
		return
	var start_pos = start_server.global_position
	var end_pos = end_server.global_position
	percent = clamp(percent + speed * delta / start_pos.distance_to(end_pos), 0, 1)
	# Move packet along interpolated position
	global_position = start_pos.lerp(end_pos, percent)
	if percent >= 1.0:
		emit_signal("packet_reached", self, start_server, end_server)
		reached = true
