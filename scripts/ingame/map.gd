class_name Map extends Node2D

@export var goal_area : Node2D
@export var world_boundary : StaticBody2D


func _ready():
	# HACK to work around WorldBoundaryShape2D ceasing effect when farther than 11000px away
	# (see https://github.com/godotengine/godot/issues/76917):
	# repeat the boundary every 22000px (since the next boundary will cover the second half)
	# until you cover the whole map
	# Note: local position works because goal_area and world_boundary have the same parent, the map
	# (which should not be offset anyway)
	var goal_distance = goal_area.position.x
	# We need one extra world boundary for every 22000px to the goal (except for the last 11000px
	# which will be covered by the last boundary toward left). Ceil to be sure to cover everything.
	# Note that this count excludes the original boundary
	var repeat_world_boundary_count = ceil((goal_distance - 11000) / 22000)
	for i in range(repeat_world_boundary_count):
		var repeated_world_boundary = world_boundary.duplicate()

		# Mind i + 1 since the first repetition is after the original
		repeated_world_boundary.position.x = (i + 1) * 22000
		world_boundary.get_parent().add_child(repeated_world_boundary)
