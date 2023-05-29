extends Node

## Application Manager
## Define it as autoload singleton scene
##
## Input Map
## Define input for the following actions:
##   app_prev_resolution
##   app_next_resolution
##   app_toggle_fullscreen
##   app_toggle_debug_fps
##   app_take_screenshot
##   app_exit


## Control showing current FPS
@export var fps_control: Control

## If true, auto-switch to fullscreen on standalone game start
@export var auto_fullscreen_in_standalone: bool = false

## Array of resolution presets
@export var preset_resolutions: Array[Vector2i] = [
		Vector2i(1280, 720),
		Vector2i(1920, 1080),
		Vector2i(2560, 1440),
		Vector2i(3840, 2160),
	]

var config = ConfigFile.new()

var current_preset_resolution_index = -1


func _ready():
	assert(fps_control != null,	"[InGameManager] fps_control is not set on %s" % get_path())

	if DisplayServer.window_get_mode() not in \
			[DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN] and \
			auto_fullscreen_in_standalone:
		if OS.has_feature("standalone"):
			print("[AppManager] Playing standalone game with auto-fullscreen ON, enabling fullscreen")
			call_deferred(&"toggle_fullscreen")

	# Show FPS by default in editor/debug exports. Else, wait for user to toggle it.
	fps_control.visible = OS.has_feature("debug")


func _unhandled_input(event: InputEvent):
	# let user toggle hi-dpi resolution freely
	# (hi-dpi is hard to detect and resize is hard to force on start)
	if event.is_action_pressed(&"app_prev_resolution"):
		change_resolution(-1)
	elif event.is_action_pressed(&"app_next_resolution"):
		change_resolution(1)

	if event.is_action_pressed(&"app_toggle_fullscreen"):
		toggle_fullscreen()
	if event.is_action_pressed(&"app_toggle_debug_fps"):
		toggle_debug_fps()

	if event.is_action_pressed(&"app_take_screenshot"):
		take_screenshot()

	if event.is_action_pressed(&"app_exit"):
		get_tree().quit()


func change_resolution(delta: int):
	# Redo this every time in case user changed monitor during game (rare)
	var screen_size = DisplayServer.screen_get_size()

	# Filter out preset resolutions bigger than screen size
	var valid_preset_resolutions = []
	for preset_resolution in preset_resolutions:
		if preset_resolution.x <= screen_size.x and \
				preset_resolution.y <= screen_size.y:
			valid_preset_resolutions.append(preset_resolution)

	if valid_preset_resolutions.is_empty():
		push_error("[AppManager] change_resolution: all preset resolutions are ",
			"bigger than screen size, STOP")
		return

	var new_preset_resolution_index
	if current_preset_resolution_index == -1:
		if delta > 0:
			new_preset_resolution_index = 0
		else:
			new_preset_resolution_index = valid_preset_resolutions.size() - 1
	else:
		new_preset_resolution_index = (current_preset_resolution_index + delta) % \
			valid_preset_resolutions.size()

	if current_preset_resolution_index == new_preset_resolution_index:
		return

	current_preset_resolution_index = new_preset_resolution_index

	var new_preset_resolution = valid_preset_resolutions[new_preset_resolution_index]
	DisplayServer.window_set_size(new_preset_resolution)

	print("[AppManager] Changed to preset resolution: %s" % new_preset_resolution)

func toggle_fullscreen():
	var new_window_mode: DisplayServer.WindowMode

	# For debug, borderless window is enough
	if DisplayServer.window_get_mode() not in \
			[DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]:
		new_window_mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		print("[AppManager] Toggle fullscreen: WINDOW_MODE_EXCLUSIVE_FULLSCREEN")
	else:
		new_window_mode = DisplayServer.WINDOW_MODE_WINDOWED
		print("[AppManager] Toggle fullscreen: WINDOW_MODE_WINDOWED")

	DisplayServer.window_set_mode(new_window_mode)

	config.set_value(OptionsConstants.section_name, OptionsConstants.fullscreen_key_name,
		new_window_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	config.save(OptionsConstants.config_file_name)

	print("[AppManager] Saved fullscreen mode to user options config")


func toggle_debug_fps():
	var new_value = not fps_control.visible
	fps_control.visible = new_value

	print("[AppManager] Toggle FPS in debug overlay: %s" % new_value)


func take_screenshot():
	var datetime = Time.get_datetime_dict_from_system()

	# Make sure all numbers less than 10 are padded with a leading 0 so
	# alphabetical sorting matches sorting by date. Modify in-place.
	for key in ["month", "day", "hour", "minute", "second"]:
		datetime[key] = "%02d" % datetime[key]
	var screenshot_filename = "{year}-{month}-{day}_{hour}-{minute}-{second}.png".format(datetime)
	var screenshot_filepath = "user://Screenshots".path_join(screenshot_filename)

	# user:// should map to:
	# Windows: %APPDATA%\Godot\app_userdata\[project_name] or
	#          %APPDATA%\[project_name/custom_user_dir_name]
	# macOS: ~/Library/Application Support/Godot/app_userdata/[project_name] or
	#        ~/Library/Application Support/[project_name/custom_user_dir_name]
	# Linux: ~/.local/share/godot/app_userdata/[project_name] or
	#        ~/.local/share/[project_name/custom_user_dir_name]
	# See https://docs.godotengine.org/en/4.0/tutorials/io/data_paths.html#accessing-persistent-user-data-user
	if not DirAccess.dir_exists_absolute("user://Screenshots"):
		# no Screenshots directory in user dir, make it
		var err = DirAccess.make_dir_recursive_absolute("user://Screenshots")
		if err:
			push_error("[AppManager] Failed to make directory user://Screenshots with error code: ", err)
			return

	save_screenshot_in(screenshot_filepath)


func save_screenshot_in(screenshot_filepath: String):
	# Get image data from viewport texture (in Godot 4, this is already ready to use,
	# no need to flip_y)
	var image = get_viewport().get_texture().get_image()
	var err = image.save_png(screenshot_filepath)
	if err:
		push_error("[AppManager] Failed to save screenshot in: ", screenshot_filepath,
			" with error code: ", err)
	else:
		print("[AppManager] Saved screenshot in %s" % screenshot_filepath)
