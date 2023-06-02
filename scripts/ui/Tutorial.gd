class_name Tutorial
extends Control


@export var accept_button: Button
@export var content_label: RichTextLabel
@export var button_icon_size: int = 60
@export var button_icon_base_path: String = "res://sprites/icons/Xelu_Free_Controller&Key_Prompts/Xbox Series/XboxSeriesX"
# Prepare list of button icons, this allows us to iterate with simple replace
# Ultimately, a regex pattern matching would be more generic and allow us
# to pass any button name as long as an image exists, but would be longer to code
@export var button_names: Array[String] = ["Dpad_Left", "Dpad_Right", "Dpad_Up", "Dpad_Down", "A", "B", "X", "Y", "LB", "RB"]

var in_game_manager: InGameManager


func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")

	accept_button.grab_focus()

	# original content label should contain {time} instead of max delivery time,
	# and {A|B|X|Y} to represent button inputs, so inject them in BB code

	var max_delivery_time_string = RaceTimer.time_to_format(in_game_manager.delivery_max_time)
	var replaced_content_text := content_label.text.replace("{time}", max_delivery_time_string)

	for button_name in button_names:
		replaced_content_text = replaced_content_text.replace("{%s}" % button_name, _get_button_icon_bbcode(button_name))

	content_label.text = replaced_content_text

func _get_button_icon_bbcode(button_name: String):
	return "[img width=%d]%s_%s.png[/img]" % [button_icon_size, button_icon_base_path, button_name]

func _on_button_pressed_accept():
	close_tutorial()
	in_game_manager.enter_racing_phase()


func close_tutorial():
	visible = false
