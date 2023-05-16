extends Control


@export var outcome_label: Label
@export var time_value_label: Label
@export var powder_left_value_label: Label
@export var powder_types_left_value_label: Label
@export var replay_button: Button
@export var back_to_main_menu_button: Button

@export var outcome_text_success: String
@export var outcome_text_failure: String


func _ready():
	if GameManager.game_phase == Enums.GamePhase.SUCCESS:
		outcome_label.text = outcome_text_success
	else:
		outcome_label.text = outcome_text_failure

	var powder_stats = GameManager.powder_stats

	if powder_stats.is_empty():
		push_warning("[ResultPanel] powder_stats is empty, we must be testing Result Scene directly. ",
			"Filling with fallback stats for testing")
		powder_stats = [9, 99]

	time_value_label.text = "%.1f" % GameManager.final_racing_time
	powder_types_left_value_label.text = str(powder_stats[0])
	powder_left_value_label.text = str(powder_stats[1])

	replay_button.grab_focus()


func _disable_all_buttons():
	replay_button.disabled = true
	back_to_main_menu_button.disabled = true


func _enable_all_buttons():
	replay_button.disabled = false
	back_to_main_menu_button.disabled = false


func _on_replay_button_pressed():
	# Disable all buttons before starting fading in for safety
	_disable_all_buttons()

	GameManager.start_level()


func _on_back_to_main_menu_button_pressed():
	# Disable all buttons before starting fading in for safety
	_disable_all_buttons()

	GameManager.go_back_to_main_menu()
