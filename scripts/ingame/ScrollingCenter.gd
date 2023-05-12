class_name ScrollingCenter
extends Node2D


signal progress_changed(progression)

@export var player_character: CharacterBody2D
@export var map: Map

## Distance to place camera (and screen colliders) ahead of player character
@export var lookahead_distance: float

var _start_position
var _distance_from_goal


func _ready():
	# Wait 1 frame so children are ready
	await get_tree().process_frame
	assert(player_character, "player_character is not set on %s" % get_path())

	# Map should not be offset but to be safe, use global position
	_start_position = player_character.global_position.x
	_distance_from_goal = map.goal_area.global_position.x - _start_position

func _process(_delta):
	# position.y is always 0, just update position.x
	# Local position works because ScrollingCenter and player_character have the same parent,
	# Level (which should not be offset anyway)
	position.x = player_character.position.x + lookahead_distance
	#print("------------------------------------------------------------------------------")
	#print("px ", player_character.position.x)
	#print("sx ", _start_position)
	#print("rd ", player_character.position.x - _start_position)
	#print("td ", _distance_from_goal)
	#print("progression ", (player_character.position.x - _start_position) / _distance_from_goal)
	#print("------------------------------------------------------------------------------")
	progress_changed.emit((player_character.position.x - _start_position) / _distance_from_goal)
