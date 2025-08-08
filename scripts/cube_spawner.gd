extends Node3D

@export var cube_scene: PackedScene  # Assign your Cube.tscn here from the inspector
@onready var cube_container = $CubeContainer  # Replace with your actual cube container node path
@onready var camera = %Camera3D  # Your camera path

func _ready():
	$Control/CanvasLayer/AddCubeButton.pressed.connect(_on_add_cube_button_pressed)

func _on_add_cube_button_pressed():
	var new_cube = cube_scene.instantiate()
	new_cube.camera = camera
	cube_container.add_child(new_cube)
	
	# Optionally set the cube at origin or some default position snapped to grid
	new_cube.global_position = Vector3(0, 0, 0)
