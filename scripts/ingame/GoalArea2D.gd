extends Area2D


func _on_body_entered(body):
	var player_character_body := body as Player
	if player_character_body != null:
		player_character_body.start_success_sequence()
