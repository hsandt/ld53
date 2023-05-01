extends Area2D


func _on_body_entered(body):
	var character_body := body as Player
	if character_body != null:
		print("GOAL")
