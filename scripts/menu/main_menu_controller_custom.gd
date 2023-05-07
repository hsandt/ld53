class_name MainMenu
extends Control
signal start_game_pressed

@onready var start_game_button: Button = $%StartGameButton
@onready var options_button: Control = $%OptionsButton
@onready var credits_button: Control = $%CreditsButton
@onready var quit_button: Control = $%QuitButton
@onready var options_menu: Control = $%OptionsMenu
@onready var credits_menu: Control = $%CreditsMenu
@onready var content: Control = $%Content

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
	options_menu.show()
	content.hide()
	options_menu.on_open()

func close_options():
	content.show();
	start_game_button.grab_focus()
	options_menu.hide()

func open_credits():
	credits_menu.show()
	content.hide()
	credits_menu.on_open()

func close_credits():
	content.show();
	start_game_button.grab_focus()
	credits_menu.hide()


func _on_start_game_button_pressed():
	emit_signal("start_game_pressed")
