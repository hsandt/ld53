class_name ScrollingCenter
extends Node2D


signal progress_changed(progression)

@export var player_character: CharacterBody2D
@export var map: Map

## Distance to place camera (and screen colliders) ahead of player character
@export var lookahead_distance: float

func _ready():
	assert(player_character, "player_character is not set on %s" % get_path())

func _process(_delta):
	# position.y is always 0, just update position.x
	# Local position works because ScrollingCenter and player_character have the same parent,
	# Level (which should not be offset anyway)
	position.x = player_character.position.x + lookahead_distance
	progress_changed.emit(map.compute_progress_ratio(player_character.position.x))
