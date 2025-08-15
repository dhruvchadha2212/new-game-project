extends Node

enum InteractionMode { DRAG, PLACE_WIRE, SEND_PACKET }

var current_mode: InteractionMode = InteractionMode.DRAG

var save_path: String = "user://scene_save.json"
