extends Node3D

# References to cubes and wire
var start_cube: Node = null
var end_cube: Node = null
var speed: float = 10.0   # meters per second
var percent: float = 0.0 # progress along the wire [0,1]

# Call this to initialize and begin movement
func start_packet(start_cube_ref: Node, end_cube_ref: Node):
	start_cube = start_cube_ref
	end_cube = end_cube_ref
	# Check for wire connection
	if are_cubes_connected(start_cube, end_cube) == null:
		print("Packet cannot travel: no wire between cubes %s and %s" % [str(start_cube.cube_id), str(end_cube.cube_id)])
		queue_free()
		return
	percent = 0.0
	global_position = start_cube.global_position

# Helper to search for wire
func are_cubes_connected(a: Node, b: Node) -> bool:
	for wire_candidate in a.connected_wires:
		if wire_candidate.start_cube == a and wire_candidate.end_cube == b:
			return true
		elif wire_candidate.start_cube == b and wire_candidate.end_cube == a:
			return true
	return false

func _process(delta):
	var start_pos = start_cube.global_position
	var end_pos = end_cube.global_position
	percent = clamp(percent + speed * delta / start_pos.distance_to(end_pos), 0, 1)
	# Move packet along interpolated position
	global_position = start_pos.lerp(end_pos, percent)
	if percent >= 1.0:
		queue_free()  # Remove packet when it reaches the end
