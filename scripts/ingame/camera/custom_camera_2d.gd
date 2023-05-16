extends Camera2D


## Shake frequency (Hz)
@export var shake_frequency: float = 60.0

var in_game_manager: InGameManager

var _intensity: float = 0.0

# From https://godotengine.org/qa/438/camera2d-screen-shake-extension
# Adapted: removed timer/duration as we use continuous shake
var _period_in_ms = 0.0
var _amplitude = 0.0
var _timer = 0.0
var _last_shook_timer = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _last_offset = Vector2(0, 0)

func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")
	in_game_manager.player_character.attribute_changed.connect(_on_attribute_changed)

func _on_attribute_changed(attribute_name: StringName):
	if attribute_name == &"camera_shake_intensity":
		var intensity = in_game_manager.player_character.compute_current_attribute(&"camera_shake_intensity")
		if intensity > 0:
			# Intensity became positive or it was already and changed, so (re)start shake
			start_shake(intensity, shake_frequency)
		else:
			# No intensity, stop shake
			stop_shake()

func start_shake(intensity: float, frequency: float):
	# From https://godotengine.org/qa/438/camera2d-screen-shake-extension
	# Initialize variables.
	# Adapted:
	# - removed timer/duration as we use continuous shake
	# - just set _previous_x/y to 0 instead of a rand val
	_period_in_ms = 1.0 / frequency
	_intensity = intensity
	_previous_x = 0.0
	_previous_y = 0.0

	# Reset previous offset, if any (only useful if reshaking during shake)
	set_offset(get_offset() - _last_offset)
	_last_offset = Vector2(0, 0)

func _process(delta):
	# From https://godotengine.org/qa/438/camera2d-screen-shake-extension
	# Adapted:
	# - removed timer/duration as we use continuous shake
	# - check _period_in_ms
	# - update API to Godot 4 (randf_range)

	# Don't shake if no intensity
	# Also safeguard against infinite loops by checking _period_in_ms
	if _intensity <= 0.0 or _period_in_ms <= 0.0:
		return

	# Only shake on certain frames.
	_last_shook_timer = _last_shook_timer + delta
	# Be mathematically correct in the face of lag; usually only happens once.
	while _last_shook_timer >= _period_in_ms:
		_last_shook_timer = _last_shook_timer - _period_in_ms
		# Noise calculation logic from http://jonny.morrill.me/blog/view/14
		var new_x = randf_range(-1.0, 1.0)
		var x_component = _intensity * (_previous_x + (delta * (new_x - _previous_x)))
		var new_y = randf_range(-1.0, 1.0)
		var y_component = _intensity * (_previous_y + (delta * (new_y - _previous_y)))
		_previous_x = new_x
		_previous_y = new_y
		# Track how much we've moved the offset, as opposed to other effects.
		var new_offset = Vector2(x_component, y_component)
		set_offset(get_offset() - _last_offset + new_offset)
		_last_offset = new_offset

func stop_shake():
	_intensity = 0.0

	# Clear offset (should be zero unless there are other concurrent effects running)
	set_offset(get_offset() - _last_offset)
	pass
