extends Node


@export var main_menu_scene: PackedScene
@export var pause_menu: PauseMenu

## Speed factor for back to main menu fade out animation
@export var back_to_main_menu_fade_out_speed: float = 1.0

## Speed factor for back to main menu fade in animation
@export var back_to_main_menu_fade_in_speed: float = 1.0

func _ready():
	assert(main_menu_scene != null,
		"[InGameManager] main_menu_scene is not set on %s" % get_path())
	assert(pause_menu != null,
		"[InGameManager] pause_menu is not set on %s" % get_path())
	pause_menu.visible = false


func _unhandled_input(event):
	if (event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"pause")):
		if not pause_menu.visible:
			pause_menu.accept_event()
			pause_menu.open_pause_menu()
		# no need to close else, as pause_menu_controller_custom.gd is handling
		# this on their side

	if event.is_action_pressed(&"restart"):
		get_tree().reload_current_scene()


func _on_pause_menu_back_to_main_pressed():
	await SceneManager.change_scene_with_fade_async(main_menu_scene,
		back_to_main_menu_fade_out_speed, back_to_main_menu_fade_in_speed)
