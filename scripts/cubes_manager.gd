extends Node

## Responsible for instantiating and initialising a new cube_scene, from UI
## as well as load_manager.

@export var cube_scene: PackedScene
@export var cube_container: Node
@export var packet_manager: Node

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
		var packet = packet_manager.spawn_new_packet(start_node, end_node)
		packet.packet_reached.connect(_on_packet_reached)
		packet.send()

func _on_packet_reached(packet_id, start_node, end_node):
	var response_time_ms = 1 + randi() % 1000
	await get_tree().create_timer(response_time_ms / 1000.0).timeout
	var packet = packet_manager.spawn_new_packet(end_node, start_node)
	packet.send()
