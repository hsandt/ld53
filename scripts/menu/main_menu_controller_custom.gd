class_name MainMenu
extends Control
signal start_game_pressed

@onready var start_game_button: Button = $%StartGameButton
@onready var options_button: Control = $%OptionsButton
@onready var credits_button: Control = $%CreditsButton
@onready var quit_button: Control = $%QuitButton

@onready var title_menu: Control = $%TitleMenu
@onready var options_menu: Control = $%OptionsMenu
@onready var credits_menu: Control = $%CreditsMenu

## Stores last focused control to restore selection when exiting sub-menu
var last_focus_owner: Control

func _ready():
	start_game_button.grab_focus()

	# ADDED: remove quit button in web export
	# It would just freeze the game but cannot close the window/embedded frame anyway
	if OS.has_feature("web"):
		quit_button.visible = false

func disable_all_buttons():
	start_game_button.disabled = true
	options_button.disabled = true
	credits_button.disabled = true
	quit_button.disabled = true

func enable_all_buttons():
	start_game_button.disabled = false
	options_button.disabled = false
	credits_button.disabled = false
	quit_button.disabled = false

func quit():
	get_tree().quit()

func open_options():
	last_focus_owner = get_viewport().gui_get_focus_owner()

	options_menu.show()
	title_menu.hide()
	options_menu.on_open()

func close_options():
	title_menu.show();
	start_game_button.grab_focus()
	options_menu.hide()

	# We could of course just hardcore options_button.grab_focus(),
	# but useful to generalize if we want to create a generic menu stack later
	last_focus_owner.grab_focus()

func open_credits():
	last_focus_owner = get_viewport().gui_get_focus_owner()

	credits_menu.show()
	title_menu.hide()
	credits_menu.on_open()

func close_credits():
	title_menu.show();
	start_game_button.grab_focus()
	credits_menu.hide()

	last_focus_owner.grab_focus()


func _on_start_game_button_pressed():
	emit_signal("start_game_pressed")
