extends Node2D


@export var player_character: CharacterBody2D
@export var map: Map

var _start_position
var _distance_from_goal


## Distance to place camera (and screen colliders) ahead of player character
@export var lookahead_distance: float

signal progress_changed(progression)

func _ready():
	# Wait 1 frame so children are ready
	await get_tree().process_frame
	assert(player_character, "player_character is not set on %s" % get_path())
	_start_position = player_character.position.x
	_distance_from_goal = map.goal_area.position.x - _start_position

func _process(_delta):
	# position.y is always 0, just update position.x
	position.x = player_character.position.x + lookahead_distance
	#print("------------------------------------------------------------------------------")
	#print("px ", player_character.position.x)
	#print("sx ", _start_position)
	#print("rd ", player_character.position.x - _start_position)	
	#print("td ", _distance_from_goal)	
	#print("progression ", (player_character.position.x - _start_position) / _distance_from_goal)	
	#print("------------------------------------------------------------------------------")
	progress_changed.emit((player_character.position.x - _start_position) / _distance_from_goal)
