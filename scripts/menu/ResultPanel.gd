extends Control


@export var outcome_label: Label
@export var time_value_label: Label
@export var powder_left_value_label: Label
@export var powder_types_left_value_label: Label
@export var total_score_label: Label
@export var total_score_value_label: Label
@export var replay_button: ButtonWithCustomCursor
@export var back_to_main_menu_button: ButtonWithCustomCursor

@export var outcome_text_success: String
@export var outcome_text_failure: String

## Base powder value to multiply by time (with its own base)
## so we have some score > 0 even when no powder left
@export var base_powder_value: float = 1.0
@export var powder_multiplier: float = 1.0

## Base remaining time value to multiply by powder left (with its own base)
## so we have some score > 0 even when no time left
@export var base_remaining_time_value: float = 1.0
@export var remaining_time_multiplier: float = 1.0


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

	time_value_label.text = RaceTimer.time_to_format(GameManager.final_racing_time)

	var powder_types_left = powder_stats[0]
	var powder_left = powder_stats[1]
	powder_types_left_value_label.text = str(powder_types_left)
	powder_left_value_label.text = str(powder_left)

	var total_score = _compute_final_score(GameManager.final_racing_time, powder_stats)
	total_score_value_label.text = str(total_score)

	replay_button.grab_focus()


func _disable_all_buttons():
	replay_button.disable_interactions()
	back_to_main_menu_button.disable_interactions()


func _enable_all_buttons():
	replay_button.enable_interactions()
	back_to_main_menu_button.enable_interactions()


func _on_replay_button_pressed():
	# Disable all buttons before starting fading in for safety
	_disable_all_buttons()

	GameManager.start_level()


func _on_back_to_main_menu_button_pressed():
	# Disable all buttons before starting fading in for safety
	_disable_all_buttons()

	GameManager.go_back_to_main_menu()


func _compute_final_score(final_racing_time: float, powder_stats: Array) -> int:
	if GameManager.game_phase == Enums.GamePhase.SUCCESS:
		# Only consider floored time (like the one displayed)
		# If late (negative time) you can even get a negative contribution
		# and negative score!
		var floored_time = floori(final_racing_time)

	#	var powder_types_left = powder_stats[0]
		var powder_left = powder_stats[1]

		var total_score = floori((base_powder_value + powder_left * powder_multiplier) * \
			(base_remaining_time_value + floored_time * remaining_time_multiplier))
		return total_score
	else:
		# if we delivered too late, powder left doesn't matter
		# and time left is irrelevant, score is just 0
		return 0
