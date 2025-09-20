extends StaticBody3D

@export var packet_factory: Node

var id: String
var camera: Camera3D
var dragging = false
var connected_wires = []
var type: Globals.ServerType
## For now, one server will have one handling for a request. 
## In other words, only 1 API is exposed per server right now in this simulation.
var request_workflow: ServiceRequestWorkflow
var pending_workflows = {}

func _ready():
	add_to_group("servers")
	_add_name_label()

func handle_packet(packet):
	match packet.type:
		Globals.PacketType.REQUEST:
			handle_request(packet)
		Globals.PacketType.RESPONSE:
			handle_response(packet)

func handle_request(request_packet):
	pass # To be overridden by child classes

func handle_response(response_packet):
	pass # To be overridden by child classes

func _get_upstream_server_ids():
	var architecture_config = Globals.architecture_config.get("servers", {})
	var server_config = architecture_config.get(id, {})
	return server_config.get("dependencies", [])

func _find_server_by_id(server_id):
	for server in get_tree().get_nodes_in_group("servers"):
		if server.id == server_id:
			return server
	return null

#region Visual Logic
func add_wire(wire):
	connected_wires.append(wire)

func on_drag_start():
	dragging = true

func on_drag_end():
	dragging = false

func _process(_delta):
	if dragging:
		_move_server()
		_move_attached_wires()

func _move_server():
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)

	if dir.y != 0:
		var t = -from.y / dir.y
		var intersection = from + dir * t

		# Snap to 1 meter grid
		var snapped_pos = Vector3(
			round(intersection.x),
			0,
			round(intersection.z)
		)
		global_position = snapped_pos

func _move_attached_wires():
	for wire in connected_wires:
		wire.update_cylinder(wire.start_server.global_position, wire.end_server.global_position)

func _add_name_label():
	var name_label = Label3D.new()
	name_label.text = self.id

	name_label.position = Vector3(0.5, 0.7, 0.5) # Position it above the server server
	name_label.font_size = 42
	name_label.outline_size = 12
	name_label.modulate = Color(1, 1, 1, 0.8)
	name_label.outline_modulate = Color.BLACK
	
	# Make the label always face the camera
	name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	add_child(name_label)
#endregion
