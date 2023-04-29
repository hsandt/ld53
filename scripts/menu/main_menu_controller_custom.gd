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