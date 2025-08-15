extends Node

@export var cube_scene: PackedScene
@export var cube_container: Node

func spawn_cube(camera: Camera3D, cube_id: int = -1, position: Vector3 = Vector3.ZERO):
	if cube_scene == null or cube_container == null or camera == null:
		push_error("CubeSpawner is missing a reference!")
		return
	if cube_id == -1:
		cube_id = Time.get_ticks_msec()
	
	var new_cube = cube_scene.instantiate()
	new_cube.camera = camera
	new_cube.cube_id = cube_id
	cube_container.add_child(new_cube)
	new_cube.global_position = position
	print("Spawned cube with ID:", new_cube.cube_id)
	return new_cube
