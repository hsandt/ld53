class_name Tutorial
extends Control


@export var accept_button: Button

var in_game_manager: InGameManager


func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")

	accept_button.grab_focus()


func _on_button_pressed_accept():
	close_tutorial()
	in_game_manager.enter_racing_phase()


func close_tutorial():
	visible = false
