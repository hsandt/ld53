class_name ScrollingCenter
extends Node2D


signal progress_changed(progression)

@export var player_character: CharacterBody2D
@export var map: Map

## Distance to place camera (and screen colliders) ahead of player character
@export var lookahead_distance: float = 0.0
@export var extra_lookahead_dampen_speed: float = 100.0

@onready var camera: Camera2D = $Camera2D
@onready var start_dampen_timer: Timer = $StartDampenTimer

var extra_lookahead_distance: float
var should_dampen: bool

func _ready():
	assert(player_character, "player_character is not set on %s" % get_path())

	extra_lookahead_distance = 0.0
	should_dampen = false


func _process(delta):
	if should_dampen:
		# simple linear decrease
		extra_lookahead_distance = move_toward(extra_lookahead_distance, 0.0,
			extra_lookahead_dampen_speed * delta)
		# remember is generally negative, so we must really check for 0
		if extra_lookahead_distance == 0.0:
			# optional cleanup, since 0.0 won't go further
			should_dampen = false

	# position.y is always 0, just update position.x
	# Local position works because ScrollingCenter and player_character have the same parent,
	# Level (which should not be offset anyway)
	var new_target_position_x = player_character.position.x + lookahead_distance + extra_lookahead_distance

	# as safety, do not go more to the left that the last position
	# so even if character is slow, already pretty much to the left, and extra_lookahead_distance
	# suddenly befores a huge negative due to boost, camera won't go *backward*
	position.x = max(position.x, new_target_position_x)
	progress_changed.emit(map.compute_progress_ratio(player_character.position.x))


func set_extra_lookahead_distance_with_dampen(
		extra_distance: float, duration_before_dampen: float):
	extra_lookahead_distance = extra_distance

	# in case we were still in the middle of previous extra lookahead dampening,
	# stop dampen now
	should_dampen = false

	# (re)start timer before dampen
	start_dampen_timer.start(duration_before_dampen)


# Connected from $StartDampenTimer via signal in inspector
func _on_start_dampen_timer_timeout():
	should_dampen = true
