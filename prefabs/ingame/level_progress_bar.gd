class_name LevelProgressBar
extends Control


@export var level_progress_big_obstacle_indicator_prefab: PackedScene
@export var character_indicator: LevelProgressionCharacterIndicator
@export var big_obstacle_indicators_parent: Control

var in_game_manager: InGameManager

func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")

	# Wait 1 frame to make sure all big obstacles have registered themselves
	# then add their indicators
	await get_tree().process_frame
	add_big_obstacles()
	hide_big_obstacles()


# Connected from HUD
func on_attribute_changed(attribute_name: StringName, new_value: float):
	if attribute_name == &"progress_bar_visibility":
		modulate.a = new_value
	elif attribute_name == &"progress_bar_show_big_obstacles":
		# Bool attribute
		if new_value > 0:
			show_big_obstacles()
		else:
			hide_big_obstacles()


# Connected from HUD
func on_scrolling_center_progress_changed(progression):
	character_indicator.progression = progression


func add_big_obstacles():
	var ref = big_obstacle_indicators_parent.get_child(0)

	var map = in_game_manager.map
	for big_obstacle in map.big_obstacles:
		var level_progress_big_obstacle_indicator: Control = level_progress_big_obstacle_indicator_prefab.instantiate()
		big_obstacle_indicators_parent.add_child(level_progress_big_obstacle_indicator)

		# HACK: instantiated controls cannot use Layout Mode: Anchors, but we must use
		# Layout Mode: Position instead.
		# However, we must make sure that anchor is on top-left in Control prefab,
		# else we must reset anchor_right before moving horizontally to avoid bad
		# size (stretching)
#		level_progress_big_obstacle_indicator.anchor_right = 0

		# Then, we must place position in pixels instead of normal ratio,
		# so scale by parent width
		# Note that we set up the prefab to center the sprite relatively to the top-left
		# anchor (origin), so we don't need further adjustment.
		var max_x = big_obstacle_indicators_parent.size.x
		# Make sure to use global position for world obstacle
		var progress_ratio = map.compute_progress_ratio(big_obstacle.global_position.x)
		# We could also just multiply but lerpf is convenient if we need to offset start later
		# Make sure to set local position for indicator
		level_progress_big_obstacle_indicator.position.x = lerpf(0.0, max_x, progress_ratio)


func show_big_obstacles():
	big_obstacle_indicators_parent.visible = true


func hide_big_obstacles():
	big_obstacle_indicators_parent.visible = false
