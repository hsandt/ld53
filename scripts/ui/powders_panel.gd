class_name PowdersPanel
extends Panel


@onready var hbox: HBoxContainer = $HBoxContainer

var in_game_manager: InGameManager

var powder_panels: Array[PowderPanel]

## Stores last focused panel to restore selection when leaving pause menu
var last_focus_owner: Control


func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")

	for child in hbox.get_children():
		var powder_panel := child as PowderPanel
		if powder_panel == null:
			push_error("[Cargo] child '%s' is not a PowderPanel, cannot register" % child.get_path())
			continue

		powder_panels.append(powder_panel)

	in_game_manager.pause_menu.pause.connect(_on_pause_menu_pause)
	in_game_manager.pause_menu.resume.connect(_on_pause_menu_resume)

func focus_first_panel():
	# Focus first panel button
	# This is required for pure keyboard/gamepad control since we don't have mappings
	# for each power yet, but as least with can navigate left/right mid-action and ui_accept
	# Xenoblade-style
	powder_panels[0].button.grab_focus()

func _on_pause_menu_pause():
	# Remember which panel was focused on restore it on resume
	# Note: this works because the "pause" signal is sent before
	# PauseMenu focuses on its own first button
	last_focus_owner = get_viewport().gui_get_focus_owner()

func _on_pause_menu_resume():
	if last_focus_owner != null:
		# Restore last focused panel button
		last_focus_owner.grab_focus()

func enable_interactions():
	for powder_panel in powder_panels:
		powder_panel.enable_interactions()

func disable_interactions():
	for powder_panel in powder_panels:
		powder_panel.disable_interactions()
