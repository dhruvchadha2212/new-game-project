extends Node3D

@onready var camera: Camera3D = %Camera3D
@export var wire_scene: PackedScene

var dragged_object: Node = null
var active_wire = null

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if Globals.current_mode == Globals.InteractionMode.DRAG:
			toggle_draggability_of_clicked_cube(event)
		if Globals.current_mode ==  Globals.InteractionMode.PLACE_WIRE:
			toggle_wire_placement(event)

func toggle_draggability_of_clicked_cube(event):
	if event.pressed:
		var raycast_result = raycast_from_mouse()
		if raycast_result and raycast_result.collider:
			dragged_object = raycast_result.collider
			dragged_object.on_drag_start()
	else:
		if dragged_object:
			dragged_object.on_drag_end()
			dragged_object = null
			
func toggle_wire_placement(event):
	if event.pressed:
		var raycast_result = raycast_from_mouse()
		if raycast_result and raycast_result.collider:
			if active_wire == null:
				# First click: create wire and start placing
				active_wire = wire_scene.instantiate()
				add_child(active_wire)
				active_wire.start_wire(raycast_result.collider, camera)
			else:
				# Second click: finalize and reset
				active_wire.finalize_wire(raycast_result.collider)
				active_wire = null

func raycast_from_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var end = origin + camera.project_ray_normal(mouse_pos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	return get_world_3d().direct_space_state.intersect_ray(query)
