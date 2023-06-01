class_name HUD
extends Control


@onready var race_timer: RaceTimer = $RaceTimer
@onready var level_progress_bar: LevelProgressBar = $LevelProgressBar
@onready var new_modifier_hint: NewModifierHint = $NewModifierHint
@onready var powders_panel: PowdersPanel = $PowdersPanel
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
	in_game_manager.player_character.attribute_changed.connect(
		race_timer.on_attribute_changed)

	# hide parts not used for tutorial at first
	powders_panel.visible = false
	level_progress_bar.visible = false
	new_modifier_hint.visible = false

	# show tutorial after 1 frame, to make sure other focusable controls
	# (PowderPanel) have been disabled so we don't lose initial button focus
	tutorial.call_deferred(&"set_visible", true)


func show_powders_panel():
	powders_panel.visible = true


func show_level_progress_bar():
	level_progress_bar.visible = true


func show_new_modifier_hint(new_modifier: Modifier):
	new_modifier_hint.visible = true
	new_modifier_hint.fill_content(new_modifier)


func hide_new_modifier_hint():
	new_modifier_hint.visible = false
