extends Node

## Application Manager
## Define it as autoload singleton scene
##
## Input Map
## Define input for the following actions:
##   app_toggle_hidpi
##   app_toggle_fullscreen
##   app_take_screenshot
##   app_exit


## If true, auto-switch to fullscreen on standalone game start
@export var auto_fullscreen_in_standalone: bool = false

## Window initial size, used for hi-dpi resize
## Set on _ready
var initial_size : Vector2

## Is window at 2x resolution?
var hidpi_active = false


func _ready():
	initial_size = DisplayServer.window_get_size()

	if DisplayServer.window_get_mode() not in \
			[DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN] and \
			auto_fullscreen_in_standalone:
		if OS.has_feature("standalone"):
			print("[AppManager] Playing standalone game with auto-fullscreen ON, enabling fullscreen")
			call_deferred(&"toggle_fullscreen")


func _unhandled_input(event: InputEvent):
	# let user toggle hi-dpi resolution freely
	# (hi-dpi is hard to detect and resize is hard to force on start)
	if event.is_action_pressed(&"app_toggle_hidpi"):
		toggle_hidpi()

	if event.is_action_pressed(&"app_toggle_fullscreen"):
		toggle_fullscreen()

	if event.is_action_pressed(&"app_take_screenshot"):
		take_screenshot()

	if event.is_action_pressed(&"app_exit"):
		get_tree().quit()


func toggle_hidpi():
	if hidpi_active:
		# back to normal size
		DisplayServer.window_set_size(initial_size)
	else:
		# set hi-dpi size (nothing more than 2x window size)
		DisplayServer.window_set_size(initial_size * 2)

	# toggle
	hidpi_active = not hidpi_active
	print("[AppManager] Toggled hi-dpi size: %s" % hidpi_active)


func toggle_fullscreen():
	# For debug, borderless window is enough
	if DisplayServer.window_get_mode() not in \
			[DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		print("[AppManager] Toggled fullscreen: WINDOW_MODE_FULLSCREEN")
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		print("[AppManager] Toggled fullscreen: WINDOW_MODE_WINDOWED")


func take_screenshot():
	var datetime = Time.get_datetime_dict_from_system()

	# Make sure all numbers less than 10 are padded with a leading 0 so
	# alphabetical sorting matches sorting by date. Modify in-place.
	for key in ["month", "day", "hour", "minute", "second"]:
		datetime[key] = "%02d" % datetime[key]
	var screenshot_filename = "{year}-{month}-{day}_{hour}-{minute}-{second}.png".format(datetime)
	var screenshot_filepath = "user://Screenshots".path_join(screenshot_filename)

	# user:// should map to:
	# Unix: $HOME/.local/share/godot/app_userdata/[AppName] or $HOME/.[AppName]
	# Windows: Users\[User]\AppData\Roaming\[AppName]
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
