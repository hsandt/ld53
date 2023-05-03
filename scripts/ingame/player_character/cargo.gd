class_name Cargo
extends Node2D


var powders: Array[Powder]


func _ready():
	for child in get_children():
		var powder := child as Powder
		if powder == null:
			push_error("[Cargo] child '%s' is not a Powder, cannot register", child.get_path())
			continue

		powders.append(powder)


func connect_powders_ui(powders_panel: PowdersPanel):
	var powder_panels := powders_panel.powder_panels
	for i in range(powders.size()):
		if i >= powder_panels.size():
			push_error("[Cargo] powder_panels only has %d elements, cannot connect signal for powder #%d",
				powder_panels.size(), i)
			continue

		# Registration for UI interaction -> model
		powder_panels[i].register_observed_powder(powders[i])

		# Registration for model -> UI update
		powders[i].state_changed.connect(powder_panels[i].on_powder_state_changed)


func hurt(damage: float):
	for powder in powders:
		powder.try_take_damage(damage)
