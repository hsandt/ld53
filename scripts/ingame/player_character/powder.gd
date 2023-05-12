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

## Time left before turning into spark (custom var instead of timer for more flexibility)
var current_time_left_before_burst: float


func _ready():
	assert(data != null, "[Powder] data is not set on %s" % get_path())

	# no signal for initialization, so set state directly
	state = Enums.PowderState.IDLE
	current_modifier = null
	current_stamina = data.max_stamina
	# If 0, timer is not active
	current_time_left_before_burst = data.time_before_burst

func _physics_process(delta):
	if current_time_left_before_burst > 0:
		current_time_left_before_burst -= delta
		if current_time_left_before_burst <= 0:
			burst()

func change_state(new_state: Enums.PowderState):
	if state != new_state:
		var previous_state = state
		state = new_state
		state_changed.emit(previous_state, new_state)
	else:
		push_warning("[Powder] change_state: already in state %s" % new_state)

func burst():
	if state != Enums.PowderState.IDLE:
		push_error("[Powder] burst: current state is %s, expected IDLE. Stop." % state)
		return

	# in case burst happened not due to timeout, clear timer to avoid trying to burst again
	# later
	current_time_left_before_burst = 0

	change_state(Enums.PowderState.SPARK)
	current_modifier = data.spark_debuff_modifier

func consume():
	if state != Enums.PowderState.SPARK:
		push_error("[Powder] burst: current state is %s, expected SPARK. Stop." % state)
		return

	change_state(Enums.PowderState.CONSUMED)
	current_modifier = null

func try_take_damage(damage: float):
	if state != Enums.PowderState.IDLE:
		# powder has already burst (possibly even be consumed), due to damage
		# or timeout, so ignore further damage
		return

	current_stamina -= damage

	if current_stamina <= 0.0:
		current_stamina = 0.0
		burst()
