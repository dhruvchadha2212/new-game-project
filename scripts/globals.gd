extends Node

enum InteractionMode { DRAG, PLACE_WIRE, SEND_PACKET }
var current_mode: InteractionMode = InteractionMode.DRAG

enum ServerType { SERVICE, LOAD_BALANCER, DATABASE, CACHE, QUEUE }

enum PacketType { REQUEST, RESPONSE }

var save_path: String = "user://scene_save.json"
