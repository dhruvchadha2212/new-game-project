extends Node3D

@onready var camera: Camera3D = %Camera3D
@export var wire_scene: PackedScene
@export var wire_container: Node
@export var packet_manager: Node

var dragged_object: Node = null
var active_wire = null

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if Globals.current_mode == Globals.InteractionMode.DRAG:
			toggle_cube_drag(event)
		if Globals.current_mode ==  Globals.InteractionMode.PLACE_WIRE:
			toggle_wire_placement(event)
		if Globals.current_mode == Globals.InteractionMode.SEND_PACKET:
			trigger_packets(event)
 
func toggle_cube_drag(event):
	if event.pressed:
		var raycast_result = _raycast_from_mouse()
		if raycast_result and raycast_result.collider:
			dragged_object = raycast_result.collider
			dragged_object.on_drag_start()
	else:
		if dragged_object:
			dragged_object.on_drag_end()
			dragged_object = null
			
func toggle_wire_placement(event):
	if event.pressed:
		var raycast_result = _raycast_from_mouse()
		if raycast_result and raycast_result.collider:
			if active_wire == null:
				active_wire = wire_scene.instantiate()
				wire_container.add_child(active_wire)
				active_wire.fix_wire_start(raycast_result.collider, camera)
			else:
				active_wire.fix_wire_end(raycast_result.collider)
				active_wire = null

func trigger_packets(event):
	if event.pressed:
		var raycast_result = _raycast_from_mouse()
		if raycast_result and raycast_result.collider:
			dragged_object = raycast_result.collider
			packet_manager.send_packets_from_cube(dragged_object)

func _raycast_from_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var end = origin + camera.project_ray_normal(mouse_pos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	return get_world_3d().direct_space_state.intersect_ray(query)
