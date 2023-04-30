extends Area2D

@export var damage = 10

func _on_body_entered(body):
	if body.has_method("hurt"):
		body.hurt(damage)

