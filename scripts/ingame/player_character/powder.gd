class_name Powder
extends Node2D


## Signal sent when state changes
signal state_changed(previous_state: Enums.PowderState, new_state: Enums.PowderState)

## Associated powder data
@export var data: PowderData

## Owning cargo (set from cargo)
var cargo: Cargo

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

## Change to new state
## Call this after setting modifier so HUD can access new data
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

	# Set modifier before calling change_state so HUD can access new modifier
	current_modifier = data.spark_debuff_modifier
	change_state(Enums.PowderState.SPARK)

func consume():
	if state != Enums.PowderState.SPARK:
		push_error("[Powder] burst: current state is %s, expected SPARK. Stop." % state)
		return

	# Set modifier before calling change_state so HUD can access new modifier
	trigger_random_modifier_from(current_modifier)
	change_state(Enums.PowderState.CONSUMED)

func trigger_random_modifier_from(modifier: Modifier):
	if modifier.lucky == null and modifier.worsen == null:
		push_warning("[Powder] trigger_random_modifier_from: no lucky nor worsen defined on %s " %
			modifier.resource_path,
			"so we will just clear the current modifier")
		current_modifier = null
		return

	var trigger_lucky_effect: bool

	if modifier.lucky == null:
		# only worsen, so trigger worsen
		trigger_lucky_effect = false
	elif modifier.worsen == null:
		# only lucky, so trigger lucky
		trigger_lucky_effect = true
	else:
		# both exist, so it's random
		# BUG: type inference fails when using method from another class when
		# classes reference to each other in a circular way, so enter type manually
		var next_consume_lucky_probability_offset: float = \
			cargo.player.compute_current_attribute(&"next_consume_lucky_probability_offset")

		var total_lucky_modifier_probability := modifier.lucky_modifier_probability + \
			next_consume_lucky_probability_offset
		total_lucky_modifier_probability = clampf(total_lucky_modifier_probability, 0.0, 1.0)
		print("total_lucky_modifier_probability: ", total_lucky_modifier_probability)

		trigger_lucky_effect = Utils.exclusive_randf() < total_lucky_modifier_probability

	if trigger_lucky_effect:
		# needs access to Player; or just spawn PFX instead
#		buff_sfx_player.play()
		current_modifier = modifier.lucky
	else:
#		debuff_sfx_player.play()
		current_modifier = modifier.worsen

func try_take_damage(damage: float):
	if state != Enums.PowderState.IDLE:
		# powder has already burst (possibly even be consumed), due to damage
		# or timeout, so ignore further damage
		return

	# BUG: type inference fails when using method from another class when
	# classes reference to each other in a circular way, so enter type manually
	var individual_powder_immunity_probability: float = \
		cargo.player.compute_current_attribute(&"individual_powder_immunity_probability")
	individual_powder_immunity_probability = clampf(individual_powder_immunity_probability, 0.0, 1.0)
	print("individual_powder_immunity_probability: ", individual_powder_immunity_probability)
	if Utils.exclusive_randf() < individual_powder_immunity_probability:
		print("Immunity: powder %s takes no damage" % get_path())
		return

	var damage_factor = cargo.player.compute_current_attribute(&"damage_factor")

	# Safety clamping
	damage_factor = max(0.0, damage_factor)

	current_stamina -= damage * damage_factor

	if current_stamina <= 0.0:
		current_stamina = 0.0
		burst()

