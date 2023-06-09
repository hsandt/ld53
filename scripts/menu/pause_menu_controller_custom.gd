class_name PauseMenu
extends Control


signal pause
signal resume
signal restart_pressed
signal back_to_main_pressed

# Children
@onready var panel_container : Control = $%PanelContainer
@onready var options_menu : Control = $%OptionsMenu
@onready var resume_game_button: Button = $%ResumeGameButton


func open_pause_menu():
	#Stops game and shows pause menu
	get_tree().paused = true
	show()

	# Hide options menu in case it was visible in scene for testing
	options_menu.hide()

	# Make sure to emit signal before grabbing focus to let
	# other Controls register their last focus if the want to
	# restore it later
	emit_signal(&"pause")
	resume_game_button.grab_focus()

func close_pause_menu():
	get_tree().paused = false
	hide()
	emit_signal(&"resume")

func _on_resume_game_button_pressed():
	close_pause_menu()


func _on_options_button_pressed():
	panel_container.hide()
	options_menu.show()
	options_menu.on_open()


func _on_options_menu_close():
	options_menu.hide()
	panel_container.show()
	resume_game_button.grab_focus()


func _on_restart_button_pressed():
	# Closing the pause menu itself is not important,
	# but resuming game time is, or we'll be stuck after scene load
	close_pause_menu()
	emit_signal(&"restart_pressed")


func _on_back_to_menu_button_pressed():
	# Closing the pause menu itself is not important,
	# but resuming game time is, or we'll be stuck after scene load
	close_pause_menu()
	emit_signal(&"back_to_main_pressed")


func _on_quit_button_pressed():
	get_tree().quit()


func _unhandled_input(event):
	if event.is_action_pressed(&"pause") and visible and !options_menu.visible:
		accept_event()
		close_pause_menu()
