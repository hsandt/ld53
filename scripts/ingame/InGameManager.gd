extends Node


@export var pause_menu: PauseMenu
@export var player_character: Player


var is_going_back_to_main_menu: bool = false

func _ready():

	assert(pause_menu != null,
		"[InGameManager] pause_menu is not set on %s" % get_path())
	assert(player_character != null,
		"[InGameManager] player_character is not set on %s" % get_path())

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
	is_going_back_to_main_menu = true

	# Disable important gameplay elements as we are resuming time before
	# going back to main, so we want to avoid any further gameplay events
	# Also remember to check is_going_back_to_main_menu before doing
	# important gameplay events that could still happen when PC is disabled,
	# such as scrolling to the end of the level
	player_character.process_mode = Node.PROCESS_MODE_DISABLED

	await GameManager.go_back_to_main_menu()
