extends Node

## Responsible for instantiating and initialising a new cube_scene, from UI
## as well as load_manager.

@export var cube_scene: PackedScene
@export var cube_container: Node
@export var packet_manager: Node
@export var manager_handler: Node

func spawn_cube(camera: Camera3D, node_id: String = "-1", position: Vector3 = Vector3.ZERO):
	if node_id == "-1":
		node_id = str(Time.get_ticks_usec())
	var new_cube = cube_scene.instantiate()
	new_cube.camera = camera
	new_cube.node_id = node_id
	cube_container.add_child(new_cube)
	new_cube.global_position = position
	print("Spawned cube with ID:", new_cube.node_id)
	return new_cube

func send_packets_from(start_node):
	for wire in start_node.connected_wires:
		var end_node = null
		if wire.start_node == start_node:
			end_node = wire.end_node
		elif wire.end_node == start_node:
			end_node = wire.start_node
		else:
			push_error("Wire does not connect to this cube.")
			continue
		var request_packet = packet_manager.spawn_new_request_packet(start_node, end_node)
		request_packet.packet_reached.connect(
			manager_handler.get_manager_for_server(end_node).on_request_packet_reached)
		request_packet.send()

func on_request_packet_reached(packet, start_node, end_node):
	push_error("Abstract method 'process_request' must be implemented by subclass")
