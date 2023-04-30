extends Node


@export var pause_menu: PauseMenu


func _ready():
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
