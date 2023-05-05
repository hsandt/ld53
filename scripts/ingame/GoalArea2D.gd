extends Area2D


var in_game_manager: InGameManager


func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")


func _on_body_entered(body):
	var character_body := body as Player
	if character_body != null:
		GameManager.enter_success_phase(in_game_manager.player_character.cargo)
