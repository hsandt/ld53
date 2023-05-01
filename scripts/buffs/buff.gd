extends Control

@export var modifier: Modifier

func _on_duration_timeout():
	queue_free()

func _on_spark_button_pressed():
	$spark_button/ui_click_sfx.play()
	var buffs = get_parent()
	if randf()<0.5:
		$buff_sfx.play()
		buffs.add(modifier.lucky)
	else:
		$debuff_sfx.play()
		buffs.add(modifier.worsen)

