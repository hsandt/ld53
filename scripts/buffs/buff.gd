extends Control

@export var modifier: Modifier

func _on_duration_timeout():
	queue_free()

func _on_spark():
	if randf()<0.5:
		pass
