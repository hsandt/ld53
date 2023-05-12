class_name Utils

# Thanks to Bruno Ely
# See https://godotengine.org/qa/46915/getting-the-absolute-z-index-of-a-node
static func get_absolute_z_index(target: Node2D) -> int:
	var node = target;
	var z_index = 0;
	while node and node.is_class('Node2D'):
		z_index += node.z_index;
		if !node.z_as_relative:
			break;
		node = node.get_parent();
	return z_index;

static func exclusive_randf() -> float:
		# up to 15 decimals under zero, 0.999... is not 1.0 yet
		return min(randf(), 0.999999999999999)
