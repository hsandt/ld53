class_name PowdersPanel
extends Panel


@onready var hbox: HBoxContainer = $HBoxContainer

var in_game_manager: InGameManager

var powder_panels: Array[PowderPanel]

## Index of panel currently focused. -1 when unset
## Note that index is preserved during pause to allow restore
var _current_focused_panel_index: int


func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")

	for i in hbox.get_child_count():
		var child = hbox.get_child(i)
		var powder_panel := child as PowderPanel
		if powder_panel == null:
			push_error("[Cargo] child '%s' is not a PowderPanel, cannot register" % child.get_path())
			continue

		powder_panels.append(powder_panel)
		powder_panel.button.focus_entered.connect(_on_panel_button_focus_entered.bind(i))

	in_game_manager.pause_menu.pause.connect(_on_pause_menu_pause)
	in_game_manager.pause_menu.resume.connect(_on_pause_menu_resume)

	_current_focused_panel_index = -1

func _unhandled_input(event: InputEvent):
	if GameManager.game_phase != Enums.GamePhase.RACING:
		# Prevent powder panel navigation outside RACING to avoid e.g.
		# losing focus from Tutorial button
		return

	if event.is_action_pressed(&"prev_powder"):
		focus_previous_panel()
	elif event.is_action_pressed(&"next_powder"):
		focus_next_panel()
	elif event.is_action_pressed(&"ui_left"):
		# only entered if native UI has not caught event, for leftmost panel
		# try to focus previous panel, it will cycle to the rightmost panel
		# See https://github.com/godotengine/godot-proposals/issues/6992
		# Alternative B
		focus_previous_panel()
	elif event.is_action_pressed(&"ui_right"):
		# only entered if native UI has not caught event, for rightmost panel
		# try to focus next panel, it will cycle to the leftmost panel
		focus_next_panel()

func focus_first_panel():
	# Focus first panel button
	# This is required for pure keyboard/gamepad control since we don't have mappings
	# for each power yet, but as least with can navigate left/right mid-action and ui_accept
	# Xenoblade-style
	# This will call _on_panel_button_focus_entered and set _current_focused_panel_index
	powder_panels[0].button.grab_focus()

## Focus panel on the left, cycling if needed
## This is used for gamepad since A/D and left/right keys already do this via UI
func focus_previous_panel():
	focus_other_panel(-1)

## Focus panel on the right, cycling if needed
## This is used for gamepad since A/D and left/right keys already do this via UI
func focus_next_panel():
	focus_other_panel(1)

func focus_other_panel(delta: int):
	var next_focused_panel_index = (_current_focused_panel_index + delta) % len(powder_panels)
	# no need to set _current_focused_panel_index, since this will
	# call _on_panel_button_focus_entered via signal
	powder_panels[next_focused_panel_index].button.grab_focus()

func _on_panel_button_focus_entered(panel_index: int):
	_current_focused_panel_index = panel_index

func _on_pause_menu_pause():
	pass

func _on_pause_menu_resume():
	if _current_focused_panel_index >= 0:
		# Restore last focused panel button
		powder_panels[_current_focused_panel_index].button.grab_focus()

func enable_interactions():
	for powder_panel in powder_panels:
		powder_panel.enable_interactions()

func disable_interactions():
	for powder_panel in powder_panels:
		powder_panel.disable_interactions()
