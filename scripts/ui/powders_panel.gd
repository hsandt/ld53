class_name PowdersPanel
extends Panel


@onready var hbox: HBoxContainer = $HBoxContainer

var powder_panels: Array[PowderPanel]


func _ready():
	for child in hbox.get_children():
		var powder_panel := child as PowderPanel
		if powder_panel == null:
			push_error("[Cargo] child '%s' is not a PowderPanel, cannot register" % child.get_path())
			continue

		powder_panels.append(powder_panel)

	# Focus first panel button
	# This is required for pure keyboard/gamepad control since we don't have mappings
	# for each power yet, but as least with can navigate left/right mid-action and ui_accept
	# Xenoblade-style
	powder_panels[0].button.grab_focus()
