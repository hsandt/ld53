extends Control


@export var outcome_label: Label
@export var replay_button: Button
@export var back_to_main_menu_button: Button

@export var outcome_text_success: String
@export var outcome_text_failure: String


func _ready():
	if GameManager.game_phase == Enums.GamePhase.SUCCESS:
		outcome_label.text = outcome_text_success
	else:
		outcome_label.text = outcome_text_failure


func _disable_all_buttons():
	replay_button.disabled = true
	back_to_main_menu_button.disabled = true


func _enable_all_buttons():
	replay_button.disabled = false
	back_to_main_menu_button.disabled = false


func _on_replay_button_pressed():
	GameManager.start_level()


func _on_back_to_main_menu_button_pressed():
	# Disable all buttons before starting fading in for safety
	_disable_all_buttons()

	GameManager.go_back_to_main_menu()
