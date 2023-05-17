class_name Obstacle
extends Area2D


@export var data: ObstacleData

var in_game_manager: InGameManager


func _ready():
	assert(data != null,
		"[Obstacle] data is not set on %s" % get_path())

	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")
	in_game_manager.map.register_obstacle_if_big(self)


func _on_body_entered(body):
	if body.has_method("hurt"):
		body.hurt(data.damage)

