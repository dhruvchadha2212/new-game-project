extends Node

@export var cube_spawner: Node
@export var save_manager: Node
@export var load_manager: Node

@export var add_cube_button: Button
@export var place_wire_button: Button
@export var save_button: Button
@export var load_button: Button

func _ready():
	add_cube_button.pressed.connect(_on_add_cube)
	place_wire_button.pressed.connect(_on_place_wire)
	save_button.pressed.connect(_on_save)
	load_button.pressed.connect(_on_load)

func _on_add_cube():
	Globals.current_mode = Globals.InteractionMode.DRAG
	cube_spawner.spawn_cube()

func _on_place_wire():
	Globals.current_mode = Globals.InteractionMode.PLACE_WIRE

func _on_save():
	save_manager.save_scene_state()

func _on_load():
	load_manager.load_scene_state()
