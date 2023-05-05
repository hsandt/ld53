extends Area2D


@export var data: ObstacleData


func _ready():
	assert(data != null,
		"[Obstacle] data is not set on %s" % get_path())


func _on_body_entered(body):
	if body.has_method("hurt"):
		body.hurt(data.damage)

