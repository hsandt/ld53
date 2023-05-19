class_name NewModifierHint
extends Control


@export var new_modifier_header_label: Label
@export var new_modifier_name_label: Label
@export var bubble_polygon: Polygon2D
@export var bubble_polygon_queue_point_index: int

## Distance removed at the end of queue since anchor is placed on character mouth
## but speech bubbles always stop before character head
@export var bubble_polygon_queue_cut_distance: float = 100.0

var in_game_manager: InGameManager


func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")


func _process(_delta):
	if visible:
		var anchor = in_game_manager.player_character.speech_bubble_queue_anchor
		var pc_canvas_origin = anchor.get_global_transform_with_canvas().origin
		move_bubble_queue(pc_canvas_origin)


func fill_content(new_modifier: Modifier):
	new_modifier_name_label.text = new_modifier.description


func move_bubble_queue(global_pos: Vector2):
	var polygon_copy = bubble_polygon.polygon

	# Point position is relative to bubble
	var bubble_origin_to_target = global_pos - bubble_polygon.global_position
	var point_pos = max(0, bubble_origin_to_target.length() - bubble_polygon_queue_cut_distance) * bubble_origin_to_target.normalized()

	if bubble_polygon.global_scale.x != 0 and bubble_polygon.global_scale.y != 0:
		# Apply member-wise division by bubble global scale so we have the correct point position
		# after scale is applied
		point_pos /= bubble_polygon.global_scale

	polygon_copy[bubble_polygon_queue_point_index] = point_pos

	bubble_polygon.polygon = polygon_copy
