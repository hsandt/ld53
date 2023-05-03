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
