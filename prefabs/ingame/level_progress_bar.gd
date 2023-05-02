class_name LevelProgressBar
extends Control


func on_scrolling_center_progress_changed(progression):
	$Bar/Control/Character.progression = progression
