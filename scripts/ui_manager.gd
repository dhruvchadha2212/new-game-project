extends Node

@export var server_factory: Node
@export var save_manager: Node
@export var load_manager: Node

@export var free_drag_button: Button
@export var add_client_button: Button
@export var add_service_button: Button
@export var add_load_balancer_button: Button
@export var remove_server_button: Button
@export var place_wire_button: Button
@export var remove_wire_button: Button
@export var save_button: Button
@export var load_button: Button
@export var send_packet_button: Button

@export var server_name_input: LineEdit
@export var warning_label: Label

@export var camera: Camera3D

func _ready():
	free_drag_button.pressed.connect(_on_free_drag)
	add_client_button.pressed.connect(_on_add_client)
	add_service_button.pressed.connect(_on_add_service)
	add_load_balancer_button.pressed.connect(_on_add_load_balancer)
	remove_server_button.pressed.connect(_on_remove_server)
	place_wire_button.pressed.connect(_on_place_wire)
	remove_wire_button.pressed.connect(_on_remove_wire)
	save_button.pressed.connect(_on_save)
	load_button.pressed.connect(_on_load)
	send_packet_button.pressed.connect(_on_send_packet)

func _on_free_drag():
	Globals.current_mode = Globals.InteractionMode.DRAG
	Globals.current_collision_mask = Globals.COLLISION_MASK_SERVERS

func _on_add_client():
	_add_server(Globals.ServerType.CLIENT)
	Globals.current_mode = Globals.InteractionMode.DRAG

func _on_add_service():
	_add_server(Globals.ServerType.SERVICE)
	Globals.current_mode = Globals.InteractionMode.DRAG

func _on_add_load_balancer():
	_add_server(Globals.ServerType.LOAD_BALANCER)
	Globals.current_mode = Globals.InteractionMode.DRAG

func _on_remove_server():
	Globals.current_mode = Globals.InteractionMode.REMOVE_SERVER
	Globals.current_collision_mask = Globals.COLLISION_MASK_SERVERS

func _on_place_wire():
	Globals.current_mode = Globals.InteractionMode.PLACE_WIRE
	Globals.current_collision_mask = Globals.COLLISION_MASK_SERVERS

func _on_remove_wire():
	Globals.current_mode = Globals.InteractionMode.REMOVE_WIRE
	Globals.current_collision_mask = Globals.COLLISION_MASK_WIRES

func _on_send_packet():
	Globals.current_mode = Globals.InteractionMode.SEND_PACKET

func _on_save():
	save_manager.save_scene_state()
	save_manager.save_architecture_state()

func _on_load():
	load_manager.load_scene_state()

func _add_server(server_type):
	var server_name = server_name_input.text
	if not _is_server_name_valid(server_name):
		return
	warning_label.visible = false
	server_name_input.clear()
	server_factory.spawn_server(server_type, camera, server_name)

func _is_server_name_valid(server_name):
	if server_name.is_empty():
		warning_label.text = "Server name !"
		warning_label.visible = true
		return false
	return true
