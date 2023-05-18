class_name HUD
extends Control


@onready var powders_panel: PowdersPanel = $PowdersPanel
@onready var level_progress_bar: LevelProgressBar = $LevelProgressBar
@onready var tutorial: Tutorial = $Tutorial

var in_game_manager: InGameManager


func _ready():
		# Wait 1 frame so other nodes are ready
	await get_tree().process_frame

	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")

	# connect player powder state change to powder panels
	in_game_manager.player_character.cargo.connect_powders_ui(powders_panel)

	# connect scrolling progress change to level progress callback
	in_game_manager.scrolling_center.progress_changed.connect(
		level_progress_bar.on_scrolling_center_progress_changed)
	in_game_manager.player_character.attribute_changed.connect(
		level_progress_bar.on_attribute_changed)

	# hide parts not used for tutorial at first
	powders_panel.visible = false
	level_progress_bar.visible = false

	# show tutorial
	tutorial.visible = true


func show_powders_panel():
	powders_panel.visible = true


func show_level_progress_bar():
	level_progress_bar.visible = true
