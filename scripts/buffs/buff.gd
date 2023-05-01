extends Control

@export var modifier: Modifier

func _on_duration_timeout():
	queue_free()

func _on_spark_button_pressed():
	var buffs = get_parent()
	if randf()<0.5:
		buffs.add(modifier.lucky)
	else:
		buffs.add(modifier.worsen)

