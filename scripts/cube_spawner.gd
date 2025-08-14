extends Node3D

@export var cube_scene: PackedScene
@export var cube_container: Node
@export var camera: Camera3D

func spawn_cube(position: Vector3 = Vector3.ZERO):
	if cube_scene == null or cube_container == null or camera == null:
		push_error("CubeSpawner is missing a reference!")
		return
	
	var new_cube = cube_scene.instantiate()
	new_cube.camera = camera
	new_cube.cube_id = Time.get_ticks_msec()
	new_cube.global_position = Vector3(
		round(position.x),
		round(position.y),
		round(position.z)
	)
	
	cube_container.add_child(new_cube)
	print("Spawned cube with ID:", new_cube.cube_id)
	return new_cube
