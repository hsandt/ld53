class_name Powder
extends Node2D


## Signal sent when state changes
signal state_changed(previous_state: Enums.PowderState, new_state: Enums.PowderState)

## Associated powder data
@export var data: PowderData

## Current FSM state
var state: Enums.PowderState

## Current modifier applied, or null if none
var current_modifier: Modifier

## Stamina left before turning into spark
var current_stamina: float


func _ready():
	assert(data != null, "[Powder] data is not set on %s" % get_path())

	# no signal for initialization, so set state directly
	state = Enums.PowderState.IDLE
	current_modifier = null
	current_stamina = data.max_stamina

func change_state(new_state: Enums.PowderState):
	if state != new_state:
		var previous_state = state
		state = new_state
		state_changed.emit(previous_state, new_state)

func burst():
	change_state(Enums.PowderState.SPARK)
	current_modifier = data.spark_debuff_modifier

func consume():
	change_state(Enums.PowderState.CONSUMED)

func try_take_damage(damage: float):
	if current_stamina <= 0:
		# powder has already burst (possibly even be consumed), so ignore
		# further damage
		return

	current_stamina -= damage

	if current_stamina <= 0.0:
		current_stamina = 0.0
		burst()
