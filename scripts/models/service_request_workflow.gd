extends Resource

class_name ServiceRequestWorkflow

var upstream_ids: Array = []

var original_request_packet: Node
var current_upstream_index: int = -1

func _init(upstream_ids: Array, packet: Node):
	self.upstream_ids = upstream_ids
	self.original_request_packet = packet

func get_next_upstream_id() -> String:
	if is_complete():
		return ""
	return upstream_ids[current_upstream_index]

func advance_to_next_upstream():
	current_upstream_index += 1

func is_complete() -> bool:
	return current_upstream_index >= upstream_ids.size()
