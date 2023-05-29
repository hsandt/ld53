class_name LevelProgressBar
extends Control


@export var level_progress_big_obstacle_indicator_prefab: PackedScene
@export var character_indicator: LevelProgressionCharacterIndicator
@export var big_obstacle_indicators_parent: Control

var in_game_manager: InGameManager

## Update interval (0 when progress_bar_lag is active is inactive
## for update every frame)
var update_interval: float

## Time left in s before next progress update
## Only used when modifier progress_bar_lag is active
var time_before_next_update: float


func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")

	# Wait 1 frame to make sure all big obstacles have registered themselves
	# then add their indicators
	await get_tree().process_frame
	add_big_obstacles()
	hide_big_obstacles()

	# Setup update_interval, but we know in practice it is 0 without modifiers
	update_interval = in_game_manager.player_character.compute_current_attribute(&"progress_bar_lag")
	time_before_next_update = 0.0


func _process(delta):
	if time_before_next_update > 0:
		time_before_next_update = max(0, time_before_next_update - delta)


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
	elif attribute_name == &"progress_bar_lag":
		# Set update_interval, it will be used from next update
		update_interval = new_value
		# If update interval is now less than time_before_next_update (generally happens when it
		# is reset to 0), clamp time_before_next_update immediately so we wait update_interval
		# in the worst case (often 0 and immediately update again)
		time_before_next_update = min(time_before_next_update, update_interval)


# Connected from HUD
func on_scrolling_center_progress_changed(progression):
	if time_before_next_update <= 0:
		character_indicator.progression = progression

		# Usually this is 0 so we can keep updating every frame
		# else this will lag the next update
		time_before_next_update = update_interval


func add_big_obstacles():
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
