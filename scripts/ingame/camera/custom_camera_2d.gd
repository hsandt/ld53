extends Camera2D

# Adapted from code snippet by Hammer Bro.
# on https://godotengine.org/qa/438/camera2d-screen-shake-extension
# Changes:
# - removed timer/duration as we use continuous shake
# - switch formula to smooth lerp between fixed previous and next keys every frame
#   instead of adding a big delta every period, to be closer to Jonny Morrill's method
#   (particularly visible at low frequencies)
# - don't set previous key on initialization, and wait for next key to be set
#   at the end of next period, so we chain smoothly chain shaking of different
#   intensities
# - safety checks to avoid infinite loop
# - update API to Godot 4 (randf_range)
# - shake frequency is an exported parameter, added stop_shake_duration
# - game-specific code for the connection with the rest of the game
# - amplitude is named "intensity" but it has the same role
# - dropped support for existing offset (store offsets from different sources
#   and sum them at the end if you need to)

## Shake frequency (Hz)
@export var shake_frequency: float = 60.0

## Duration to stop shaking (s)
## You can set it to 1/shake_frequency if you want to end it as fast as the usual
## shaking moves
@export var stop_shake_duration: float = 0.0

var in_game_manager: InGameManager

# Shake parameters
var _intensity := 0.0
var _period_in_ms := 0.0

# Shake state
var _previous_key_offset := Vector2.ZERO
var _next_key_offset := Vector2.ZERO
var _shake_time_since_last_period := 0.0

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
			stop_shake(stop_shake_duration)

func start_shake(intensity: float, frequency: float):
	# Initialize parameters
	_intensity = intensity
	_period_in_ms = 1.0 / frequency

	# Initialize state
	# Set previous key offset to current offset so we can chain a new shake
	# in the middle of another shake without delay, and smoothly from the last
	# offset
	_previous_key_offset = offset
	# Immediately compute next key offset so we don't have to wait for a period
	# to take the new shake into account
	_next_key_offset = _compute_shake_next_key_random_offset()
	# Start at time 0 rather than _period_in_ms, since we've just set the next
	# key offset anyway, so we can wait a period from here before the next change
	_shake_time_since_last_period = 0.0

func _process(delta):
	# Don't shake if intensity is zero, unless an offset remains from previous
	# shake
	# (this generally means we called stop_shake with a frequency > 0 and
	# in this case, we must still process for a bit until we finish smoothly
	# reducing offset to zero)
	# Also safeguard against infinite loops by checking _period_in_ms
	if _intensity <= 0.0 and offset == Vector2.ZERO or _period_in_ms <= 0.0:
		return

	# Advance shake time
	_shake_time_since_last_period = _shake_time_since_last_period + delta

	# When we cross a period, subtract it and advance to next keypoint. Use while to
	# be mathematically correct in the face of lag; usually only happens once.
	while _shake_time_since_last_period >= _period_in_ms:
		_shake_time_since_last_period = _shake_time_since_last_period - _period_in_ms

		# Noise calculation logic from http://jonny.morrill.me/blog/view/14
		# Instead of presampling as in Jonny Morrill's method, we compute the next
		# keypoint value just on time (and store the current "next" as previous keypoint)
		_previous_key_offset = _next_key_offset
		_next_key_offset = _compute_shake_next_key_random_offset()

	# Compute fractional position on current time segment
	var alpha := _shake_time_since_last_period / _period_in_ms

	# Compute linear progression from previous to next keypoint
	var new_offset := _previous_key_offset.lerp(_next_key_offset, alpha)

	# Set final offset
	set_offset(new_offset)

## Stop shaking with optional frequency
## If frequency > 0, use its inverse as the duration to gradually stop shaking
func stop_shake(duration: float = 0.0):
	if duration <= 0.0:
		# Instant stop
		_intensity = 0.0

		# Clear offset immediately
		set_offset(Vector2.ZERO)

		# Optional cleanup
		_period_in_ms = 0.0
		_previous_key_offset = Vector2.ZERO
		_next_key_offset = Vector2.ZERO
		_shake_time_since_last_period = 0.0
	else:
		# As a trick to stop shaking gradually over stop_shake_duration
		# is to start a new shake at intensity 0 and
		# frequency = 1 / stop_shake_duration
		# then let it reach the next key point at (0, 0).
		# The second next key point will also be (0, 0) which guarantees that
		# processing will stop as lerp between (0, 0) and (0, 0) is (0, 0)
		# so the condition at the top of _process
		# (_intensity <= 0.0 and offset == Vector2.ZERO) will be entered.
		start_shake(0.0, 1.0 / stop_shake_duration)

func _compute_shake_next_key_random_offset():
	return _intensity * Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
