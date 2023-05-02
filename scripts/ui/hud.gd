class_name HUD
extends Control


@onready var powder_panel: PowderPanel = $powderpanel
@onready var level_progress_bar: LevelProgressBar = $LevelProgressBar

var in_game_manager: InGameManager


func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")

	# connect scrolling progress change to level progress callback
	in_game_manager.scrolling_center.progress_changed.connect(
		level_progress_bar.on_scrolling_center_progress_changed)
