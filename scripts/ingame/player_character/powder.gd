class_name Powder
extends Node2D


## Signal sent when state changes
signal state_changed(new_state: Enums.PowderState)

## Associated powder data
@export var data: PowderData

## Current FSM state
var state: Enums.PowderState

## Current modifier applied, or null if none
var current_modifier: Modifier

## stamina left before turning into spark
var _current_stamina: float


func _ready():
	assert(data != null, "[Powder] data is not set on %s" % get_path())

	# no signal for initialization, so set state directly
	state = Enums.PowderState.IDLE
	current_modifier = null
	_current_stamina = data.max_stamina

func change_state(new_state: Enums.PowderState):
	if state != new_state:
		state = new_state
		state_changed.emit(new_state)

func burst():
	change_state(Enums.PowderState.SPARK)
	current_modifier = data.spark_debuff_modifier

func consume():
	change_state(Enums.PowderState.CONSUMED)

func try_take_damage(damage: float):
	if _current_stamina <= 0:
		# powder has already burst (possibly even be consumed), so ignore
		# further damage
		return

	_current_stamina -= damage

	if _current_stamina <= 0.0:
		_current_stamina = 0.0
		burst()
