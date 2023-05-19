class_name Cargo
extends Node2D


## Owning player. Should be set by Player on ready
var player: Player

## Cached array of powder children
var powders: Array[Powder]

## Cached number of powder that are either in BURST or CONSUMED state
var powder_burst_or_consumed_count: int


func _ready():
	for child in get_children():
		var powder := child as Powder
		if powder == null:
			push_error("[Cargo] child '%s' is not a Powder, cannot register", child.get_path())
			continue

		# Register
		powders.append(powder)

		# Back reference
		powder.cargo = self

	powder_burst_or_consumed_count = 0


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
		powders[i].state_changed.connect(_on_powder_state_changed.bind(i))


func hurt(damage: float):
	for powder in powders:
		powder.try_take_damage(damage)


## Return an array of [modifier factor, modifier offset] by cumulating
## all the modifiers for the passed attribute from all powders for multiply and
## add operations respectively
func get_attribute_modifier_factor_and_offset(attribute_name: StringName) -> Array[float]:
	# Initialize cumulated factor and offset with their base value
	var cumulated_modifier_factor = 1.0
	var cumulated_modifier_offset = 0.0

	for powder in powders:
		var modifier = powder.current_modifier

		if modifier == null or modifier.attribute != attribute_name:
			continue

		match modifier.operation:
			Enums.ModifierOperation.MULTIPLY:
				cumulated_modifier_factor *= modifier.value
			Enums.ModifierOperation.ADD:
				cumulated_modifier_offset += modifier.value

	return [cumulated_modifier_factor, cumulated_modifier_offset]


## Return powder stats: [idle_powder_count, total_powder_stamina]
func get_powder_stats() -> Array:
	var idle_powder_count: int = 0
	var total_powder_stamina: float = 0.0
	for powder in powders:
		if powder.state == Enums.PowderState.IDLE:
			idle_powder_count += 1
			total_powder_stamina += powder.current_stamina
	return [idle_powder_count, total_powder_stamina]


func _on_powder_state_changed(previous_state: Enums.PowderState, new_state: Enums.PowderState, _powder_index: int):
	if previous_state == Enums.PowderState.IDLE and new_state != Enums.PowderState.IDLE:
		powder_burst_or_consumed_count += 1

	if powder_burst_or_consumed_count >= powders.size():
		# no failure anymore
		pass
