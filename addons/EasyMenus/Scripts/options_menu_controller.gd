extends Control
signal  close

const HSliderWLabel = preload("res://addons/EasyMenus/Scripts/slider_w_labels.gd")

@onready var sfx_volume_slider : HSliderWLabel = $%SFXVolumeSlider
@onready var music_volume_slider: HSliderWLabel = $%MusicVolumeSlider
@onready var fullscreen_check_button: CheckButton = $%FullscreenCheckButton
@onready var render_scale_current_value_label: Label = $%RenderScaleCurrentValueLabel
@onready var render_scale_slider: HSlider = $%RenderScaleSlider
@onready var vsync_check_button: CheckButton = $%VSyncCheckButton
# ADDED to hide when not relevant
@onready var anti_aliasing_2d_label: Label = $%AntiAliasing2DLabel
@onready var anti_aliasing_2d_option_button: OptionButton = $%AntiAliasing2DOptionButton
@onready var anti_aliasing_3d_option_button: OptionButton = $%AntiAliasing3DOptionButton
@onready var back_button: Button = $%BackButton

var sfx_bus_index
var music_bus_index
var config = ConfigFile.new()

## Stores last focused control to restore selection when re-entering this sub-menu
## (except if we were selecting the Back button, which is not interesting to focus)
var last_non_back_focus_owner: Control


func _ready():
	# ADDED: Disable options irrelevant to web or desktop using Compatibility renderer
	# See https://github.com/SavoVuksan/EasyMenus/issues/7
	if OS.has_feature("web"):
		vsync_check_button.visible = false
	if OS.has_feature("web") or \
			ProjectSettings.get_setting("rendering/renderer/rendering_method") == "gl_compatibility":
		anti_aliasing_2d_label.visible = false
		anti_aliasing_2d_option_button.visible = false

# Emits close signal and saves the options
func go_back():
	# Store last focus except if it's Back button, which we don't want to focus
	# when coming back as it doesn't help editing options faster
	var last_focus_owner = get_viewport().gui_get_focus_owner()
	if last_focus_owner != back_button:
		last_non_back_focus_owner = get_viewport().gui_get_focus_owner()
	else:
		last_non_back_focus_owner = null

	save_options()
	emit_signal("close")

# Called from outside initializes the options menu
func on_open():
	# ADDED: Local fix for https://github.com/SavoVuksan/EasyMenus/issues/6
	# Auto-scroll to top when options menu is opened
	$MarginContainer/ScrollContainer.scroll_vertical = 0

	if last_non_back_focus_owner != null:
		last_non_back_focus_owner.grab_focus()
	else:
		sfx_volume_slider.hslider.grab_focus()

	sfx_bus_index = AudioServer.get_bus_index(OptionsConstants.sfx_bus_name)
	music_bus_index = AudioServer.get_bus_index(OptionsConstants.music_bus_name)

	load_options()

func _on_sfx_volume_slider_value_changed(value):
	set_volume(sfx_bus_index, value)

func _on_music_volume_slider_value_changed(value):
	set_volume(music_bus_index, value)

# Sets the volume for the given audio bus
func set_volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

# Saves the options when the options menu is closed
func save_options():
	config.set_value(OptionsConstants.section_name,OptionsConstants.sfx_volume_key_name, sfx_volume_slider.hslider.value)
	config.set_value(OptionsConstants.section_name, OptionsConstants.music_volume_key_name, music_volume_slider.hslider.value)

	# ADDED: Only save fullscreen option if not web, since we won't load it for web anyway
	if not OS.has_feature("web"):
		config.set_value(OptionsConstants.section_name, OptionsConstants.fullscreen_key_name, fullscreen_check_button.button_pressed)

	config.set_value(OptionsConstants.section_name, OptionsConstants.render_scale_key, render_scale_slider.value);

	# ADDED: Only save those two options if corresponding widgets are visible
	if vsync_check_button.visible:
		config.set_value(OptionsConstants.section_name, OptionsConstants.vsync_key, vsync_check_button.button_pressed)
	if anti_aliasing_2d_option_button.visible:
		config.set_value(OptionsConstants.section_name, OptionsConstants.msaa_2d_key, anti_aliasing_2d_option_button.get_selected_id())

	config.set_value(OptionsConstants.section_name, OptionsConstants.msaa_3d_key, anti_aliasing_3d_option_button.get_selected_id())

	config.save(OptionsConstants.config_file_name)

# Loads options and sets the controls values to loaded values. Uses default values if config file
# does not exist
func load_options():
	var err = config.load(OptionsConstants.config_file_name)

	var sfx_volume = config.get_value(OptionsConstants.section_name, OptionsConstants.sfx_volume_key_name, 1)
	var music_volume = config.get_value(OptionsConstants.section_name, OptionsConstants.music_volume_key_name, 1)
	var fullscreen = config.get_value(OptionsConstants.section_name, OptionsConstants.fullscreen_key_name, false)
	var render_scale = config.get_value(OptionsConstants.section_name, OptionsConstants.render_scale_key, 1)
	var msaa_3d = config.get_value(OptionsConstants.section_name, OptionsConstants.msaa_3d_key, 0)

	sfx_volume_slider.hslider.value = sfx_volume
	music_volume_slider.hslider.value = music_volume
	fullscreen_check_button.button_pressed = fullscreen
	render_scale_slider.value = render_scale

	# ADDED: Only update VSync if button is visible, so web also skips this step and avoids console error
	# Also MOVED get_value inside this block so it's not only assigned when used
	# See https://github.com/SavoVuksan/EasyMenus/issues/7
	if vsync_check_button.visible:
		var vsync = config.get_value(OptionsConstants.section_name, OptionsConstants.vsync_key, true)
		# Need to set it like that to guarantee signal to be triggered
		vsync_check_button.set_pressed_no_signal(vsync)
		vsync_check_button.emit_signal("toggled", vsync)

	# ADDED: Only update VSync if button is visible, so web also skips this step and avoids console error
	# Also MOVED get_value inside this block so it's not only assigned when used
	# See https://github.com/SavoVuksan/EasyMenus/issues/7
	if anti_aliasing_2d_option_button.visible:
		var msaa_2d = config.get_value(OptionsConstants.section_name, OptionsConstants.msaa_2d_key, 0)
		anti_aliasing_2d_option_button.selected = msaa_2d
		anti_aliasing_2d_option_button.emit_signal("item_selected", msaa_2d)

	anti_aliasing_3d_option_button.selected = msaa_3d
	anti_aliasing_3d_option_button.emit_signal("item_selected", msaa_3d)

func _on_fullscreen_check_button_toggled(button_pressed):
	if button_pressed:
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_render_scale_slider_value_changed(value):
	get_viewport().scaling_3d_scale = value
	render_scale_current_value_label.text = str(value)


func _on_v_sync_check_button_toggled(button_pressed):
	# There are multiple V-Sync Methods supported by Godot
	# For now we just use the simple ones could be worth a consideration to
	# add the others
	# Just sets V-Sync for the first window. So no support for multi window games
	if button_pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_anti_aliasing_2d_option_button_item_selected(index):
	set_msaa("msaa_2d", index)

func _on_anti_aliasing_3d_option_button_item_selected(index):
	set_msaa("msaa_3d", index)

func set_msaa(mode, index):
	match index:
		0:
			get_viewport().set(mode,Viewport.MSAA_DISABLED)
		1:
			get_viewport().set(mode,Viewport.MSAA_2X)
		2:
			get_viewport().set(mode,Viewport.MSAA_4X)
		3:
			get_viewport().set(mode,Viewport.MSAA_8X)

func _input(event):
	if event.is_action_pressed("ui_cancel") && visible:
		accept_event()
		go_back()
