extends Node
#Loads options like volume and graphic options on game startup

var config = ConfigFile.new()

# Loads settings from config file. Loads with standard values if settings not
# existing
func load_settings():
	var err = config.load(OptionsConstants.config_file_name)

	if err != OK:
		return

	var sfx_bus_index = AudioServer.get_bus_index(OptionsConstants.sfx_bus_name)
	var music_bus_index = AudioServer.get_bus_index(OptionsConstants.music_bus_name)
	var sfx_volume = linear_to_db(config.get_value(OptionsConstants.section_name, OptionsConstants.sfx_volume_key_name, 1))
	var music_volume = linear_to_db(config.get_value(OptionsConstants.section_name, OptionsConstants.music_volume_key_name, 1))
	var render_scale = config.get_value(OptionsConstants.section_name, OptionsConstants.render_scale_key, 1)
	var msaa_3d = config.get_value(OptionsConstants.section_name, OptionsConstants.msaa_3d_key, 0)

	AudioServer.set_bus_volume_db(sfx_bus_index, sfx_volume)
	AudioServer.set_bus_volume_db(music_bus_index, music_volume)

	# ADDED to avoid error on start on web
	# Also MOVED get_value inside this block so it's not only assigned when used
	# See https://github.com/SavoVuksan/EasyMenus/issues/7
	if not OS.has_feature("web"):
		var fullscreen = config.get_value(OptionsConstants.section_name, OptionsConstants.fullscreen_key_name, false)
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	get_viewport().scaling_3d_scale = render_scale

	# ADDED to avoid error on start on web
	# Also MOVED get_value inside this block so it's not only assigned when used
	# See https://github.com/SavoVuksan/EasyMenus/issues/7
	if not OS.has_feature("web"):
		var vsync = config.get_value(OptionsConstants.section_name, OptionsConstants.vsync_key, true)
		if vsync:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	# ADDED to avoid error on start on web (generally doesn't happen since 2D MSAA dropdown should be
	# hidden so preferene should never have been set, but to be safe in case somebody saved an old
	# preference e.g. with an old version of Easy Menus
	# Also MOVED get_value inside this block so it's not only assigned when used
	# See https://github.com/SavoVuksan/EasyMenus/issues/7
	if not OS.has_feature("web") and \
			ProjectSettings.get_setting("rendering/renderer/rendering_method") != "gl_compatibility":
		var msaa_2d = config.get_value(OptionsConstants.section_name, OptionsConstants.msaa_2d_key, 0)
		set_msaa("msaa_2d", msaa_2d)

	set_msaa("msaa_3d", msaa_3d)

func _ready():
	load_settings()

func set_msaa(mode, index):
	match index:
		0:
			get_viewport().set(mode, Viewport.MSAA_DISABLED)
		1:
			get_viewport().set(mode, Viewport.MSAA_2X)
		2:
			get_viewport().set(mode, Viewport.MSAA_4X)
		3:
			get_viewport().set(mode, Viewport.MSAA_8X)
