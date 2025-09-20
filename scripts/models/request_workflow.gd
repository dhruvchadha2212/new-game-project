extends Resource

class_name RequestWorkflow

var upstream_ids: Array = []

var original_request_packet: Node
var current_upstream_index: int = 0

func _init(upstream_ids: Array):
	self.upstream_ids = upstream_ids

func set_original_request_packet(packet: Node):
	self.original_request_packet = packet

func get_next_upstream_id() -> String:
	if is_complete():
		return ""
	return upstream_ids[current_upstream_index]

func advance_to_next_upstream():
	current_upstream_index += 1

func is_complete() -> bool:
	return current_upstream_index >= upstream_ids.size()
