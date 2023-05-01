extends Node2D


@export var player_character: CharacterBody2D

## Distance to place camera (and screen colliders) ahead of player character
@export var lookahead_distance: float


func _ready():
	assert(player_character, "player_character is not set on %s" % get_path())


func _process(_delta):
	# position.y is always 0, just update position.x
	position.x = player_character.position.x + lookahead_distance
