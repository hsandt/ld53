class_name PauseMenu
extends Control


signal pause
signal resume
signal back_to_main_pressed

# Children
@onready var content : VBoxContainer = $%Content
@onready var options_menu : Control = $%OptionsMenu
@onready var resume_game_button: Button = $%ResumeGameButton


func open_pause_menu():
	#Stops game and shows pause menu
	get_tree().paused = true
	show()
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
	content.hide()
	options_menu.show()
	options_menu.on_open()


func _on_options_menu_close():
	options_menu.hide()
	content.show()
	resume_game_button.grab_focus()

func _on_quit_button_pressed():
	get_tree().quit()


func _on_back_to_menu_button_pressed():
	close_pause_menu()
	emit_signal(&"back_to_main_pressed")

func _unhandled_input(event):
	if event.is_action_pressed(&"pause") and visible and !options_menu.visible:
		accept_event()
		close_pause_menu()
