class_name BoostLevelIndicator
extends Control


@onready var progress_bar: ProgressBar = $ProgressBar


func setup(initial_boost_level: int, boost_max_level: int):
	progress_bar.value = initial_boost_level
	progress_bar.max_value = boost_max_level


func _on_player_character_body_2d_boost_level_changed(new_level):
	progress_bar.value = new_level
