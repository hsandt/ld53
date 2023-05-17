class_name LevelProgressBar
extends Control


# Connected from HUD
func on_attribute_changed(attribute_name: StringName, new_value: float):
	if attribute_name == &"progress_bar_visibility":
		modulate.a = new_value


# Connected from HUD
func on_scrolling_center_progress_changed(progression):
	$Frame/Control/Character.progression = progression
