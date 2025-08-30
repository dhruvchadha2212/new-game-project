extends Node3D

## Responsible for moving an instantiated packet_scene from start node to end node
## and emitting a signal when done.

signal packet_reached(packet, start_node, end_node)

var start_node: Node = null
var end_node: Node = null
var speed: float = 10.0   # meters per second
var percent: float = 0.0 # progress along the wire [0,1]
var packet_id: String
var type: Globals.PacketType

func initialize_id():
	var base_id = Time.get_ticks_usec()
	var random_suffix = randi() % 10000
	self.packet_id = str(base_id) + "_" + str(random_suffix)

# Call this to initialize and begin movement
func send():
	# Check for wire connection
	if are_cubes_connected(start_node, end_node) == null:
		print("Packet cannot travel: no wire between cubes %s and %s" % [str(start_node.cube_id), str(end_node.cube_id)])
		queue_free()
		return
	percent = 0.0
	global_position = start_node.global_position

# Helper to search for wire
func are_cubes_connected(a: Node, b: Node) -> bool:
	for wire_candidate in a.connected_wires:
		if wire_candidate.start_node == a and wire_candidate.end_node == b:
			return true
		elif wire_candidate.start_node == b and wire_candidate.end_node == a:
			return true
	return false

func _process(delta):
	var start_pos = start_node.global_position
	var end_pos = end_node.global_position
	percent = clamp(percent + speed * delta / start_pos.distance_to(end_pos), 0, 1)
	# Move packet along interpolated position
	global_position = start_pos.lerp(end_pos, percent)
	if percent >= 1.0:
		emit_signal("packet_reached", self, start_node, end_node)
		queue_free()  # Remove packet when it reaches the end
