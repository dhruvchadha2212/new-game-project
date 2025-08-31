extends Node

@export var service_manager: Node
@export var load_balancer_manager: Node
@export var save_manager: Node
@export var load_manager: Node

@export var add_service_button: Button
@export var add_load_balancer_button: Button
@export var place_wire_button: Button
@export var save_button: Button
@export var load_button: Button
@export var send_packet_button: Button

@export var camera: Camera3D

func _ready():
	add_service_button.pressed.connect(_on_add_service)
	add_load_balancer_button.pressed.connect(_on_add_load_balancer)
	place_wire_button.pressed.connect(_on_place_wire)
	save_button.pressed.connect(_on_save)
	load_button.pressed.connect(_on_load)
	send_packet_button.pressed.connect(_on_send_packet)

func _on_add_service():
	Globals.current_mode = Globals.InteractionMode.DRAG
	service_manager.spawn_server(camera)

func _on_add_load_balancer():
	Globals.current_mode = Globals.InteractionMode.DRAG
	load_balancer_manager.spawn_server(camera)

func _on_place_wire():
	Globals.current_mode = Globals.InteractionMode.PLACE_WIRE

func _on_send_packet():
	Globals.current_mode = Globals.InteractionMode.SEND_PACKET

func _on_save():
	save_manager.save_scene_state()

func _on_load():
	load_manager.load_scene_state()
