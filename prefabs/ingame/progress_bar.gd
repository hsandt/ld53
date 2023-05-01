extends Control

func _on_scrolling_center_progress_changed(progression):
	$Bar/Control/Character.progression = progression
