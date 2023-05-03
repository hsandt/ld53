class_name Powder
extends Node2D


signal state_changed(new_state: Enums.PowderState)

@export var data: PowderData

## Current FSM state
var state: Enums.PowderState

## Stamina left before turning into spark
var stamina: float


func _ready():
	assert(data != null, "[Powder] data is not set on %s" % get_path())

	# no signal for initialization, so set state directly
	state = Enums.PowderState.IDLE
	stamina = data.max_stamina

func change_state(new_state: Enums.PowderState):
	if state != new_state:
		state = new_state
		state_changed.emit(new_state)

func burst():
	change_state(Enums.PowderState.SPARK)

func consume():
	change_state(Enums.PowderState.CONSUMED)

func try_take_damage(damage: float):
	if stamina <= 0:
		# powder has already burst (possibly even be consumed), so ignore
		# further damage
		return

	stamina -= damage

	if stamina <= 0.0:
		stamina = 0.0
		burst()
