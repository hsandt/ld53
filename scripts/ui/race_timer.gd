class_name RaceTimer
extends Control


@export var time_label: Label
@export var negative_time_color: Color = Color.RED

var in_game_manager: InGameManager


func _ready():
	assert(time_label != null, "[Powder] time_label is not set on %s" % get_path())

	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")

func _process(_delta):
	var racing_time_left = in_game_manager.racing_time_left

	# Text format
	time_label.text = RaceTimer.time_to_format(racing_time_left)

	# Color
	if racing_time_left < 0.0:
		# The first time it changed to negative,
		if not time_label.has_theme_color_override(&"font_color"):
			time_label.add_theme_color_override(&"font_color", negative_time_color)
	else:
		# We cannot really get back to positive but to be complete
		if time_label.has_theme_color_override(&"font_color"):
			time_label.remove_theme_color_override(&"font_color")


# Connected from HUD
func on_attribute_changed(attribute_name: StringName, new_value: float):
	if attribute_name == &"race_timer_visibility":
		modulate.a = new_value


static func split_time_in_sign_minutes_seconds(racing_time_left: float):
	# Floor first (for negative, it will become "-0:01" as soon as you get under 0
	# but this is better than flooring after abs which would cause "0:00" to show
	# for 2 seconds if going negative)
	var floored_racing_time_left = floori(racing_time_left)

	# Abs time
	var abs_floored_racing_time_left = absi(floored_racing_time_left)
	@warning_ignore("integer_division")
	var abs_minutes = abs_floored_racing_time_left / 60
	# Equivalent to `abs_floored_racing_time_left - 60 * abs_minutes`
	var abs_seconds = abs_floored_racing_time_left % 60

	return [signf(racing_time_left), abs_minutes, abs_seconds]


static func time_to_format(racing_time_left: float) -> String:
	var split_time_info = split_time_in_sign_minutes_seconds(racing_time_left)
	var abs_minutes = split_time_info[1]
	var abs_seconds = split_time_info[2]

	var abs_time_text = "%d:%02d" % [abs_minutes, abs_seconds]

	# Sign (in case we tolerate negative time)
	var sign_prefix
	if racing_time_left < 0.0:
		sign_prefix = "-"
	else:
		sign_prefix = ""

	# Format: "(-)m:ss"
	return "%s%s" % [sign_prefix, abs_time_text]
