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

		# Disable collider to prevent further hit (when exiting or re-entering quickly,
		# or because we paused and resumed whole Player node for Burst sequence)
		disable_collider()


func disable_collider():
	# We are inside in/out signal so we must defer physics state change
	set_deferred("monitoring", false)
	# Optional since we are checking _on_body_entered on this side, but for completion
	set_deferred("monitorable", false)
