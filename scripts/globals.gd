extends Node

enum InteractionMode { DRAG, PLACE_WIRE, REMOVE_WIRE, SEND_PACKET, REMOVE_SERVER }
var current_mode: InteractionMode = InteractionMode.DRAG

enum ServerType { CLIENT, SERVICE, LOAD_BALANCER, DATABASE, CACHE, QUEUE }

enum PacketType { REQUEST, RESPONSE, MESSAGE }

enum Protocol { HTTP, AMQP }

var save_path: String = "user://scene_save.json"

const COLLISION_MASK_WIRES = 1 << 0
const COLLISION_MASK_SERVERS = 1 << 1
const COLLISION_MASK_DEFAULT = 0x7FFFFFFF
var current_collision_mask = COLLISION_MASK_DEFAULT

var architecture_config: Dictionary = {}

func _ready():
	_load_architecture_config()

func _load_architecture_config():
	var file = FileAccess.open("res://architecture.json", FileAccess.READ)
	if not FileAccess.file_exists("res://architecture.json"):
		print("ERROR: architecture.json not found!")
		return
		
	var content = JSON.parse_string(file.get_as_text())
	if content:
		architecture_config = content
		print("Architecture config loaded successfully.")
	else:
		print("ERROR: Failed to parse architecture.json")
