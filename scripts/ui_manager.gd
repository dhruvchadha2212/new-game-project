extends Node

@export var server_factory: Node
@export var save_manager: Node
@export var load_manager: Node

@export var free_drag_button: Button
@export var add_service_button: Button
@export var add_load_balancer_button: Button
@export var place_wire_button: Button
@export var remove_wire_button: Button
@export var save_button: Button
@export var load_button: Button
@export var send_packet_button: Button

@export var camera: Camera3D

func _ready():
	free_drag_button.pressed.connect(_on_free_drag)
	add_service_button.pressed.connect(_on_add_service)
	add_load_balancer_button.pressed.connect(_on_add_load_balancer)
	place_wire_button.pressed.connect(_on_place_wire)
	remove_wire_button.pressed.connect(_on_remove_wire)
	save_button.pressed.connect(_on_save)
	load_button.pressed.connect(_on_load)
	send_packet_button.pressed.connect(_on_send_packet)

func _on_free_drag():
	Globals.current_mode = Globals.InteractionMode.DRAG
	Globals.current_collision_mask = Globals.COLLISION_MASK_SERVERS

func _on_add_service():
	server_factory.spawn_server(Globals.ServerType.SERVICE, camera)

func _on_add_load_balancer():
	server_factory.spawn_server(Globals.ServerType.LOAD_BALANCER, camera)

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

func _on_load():
	load_manager.load_scene_state()
