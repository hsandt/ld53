class_name PowderPanel
extends Panel


@export var animated_sprite: AnimatedSprite2D

@onready var button: Button = %Button


var powder_state_to_animation := {
	Enums.PowderState.IDLE: &"idle",
	Enums.PowderState.SPARK: &"spark",
	Enums.PowderState.CONSUMED: &"consumed",
}

var observed_powder: Powder


func _ready():
	assert(animated_sprite, "animated_sprite is not set on %s" % get_path())

func register_observed_powder(powder: Powder):
	observed_powder = powder

func on_powder_state_changed(_previous_state: Enums.PowderState, new_state: Enums.PowderState):
	animated_sprite.animation = powder_state_to_animation[new_state]

func _on_button_pressed():
	if observed_powder == null:
		return

	match observed_powder.state:
		Enums.PowderState.IDLE:
			push_error("[PowderPanel] _on_button_pressed: observed_powder %s "
				% observed_powder.get_path(),
				"is IDLE, so button should not even be enabled")
		Enums.PowderState.SPARK:
			observed_powder.consume()
		Enums.PowderState.CONSUMED:
			push_error("[PowderPanel] _on_button_pressed: observed_powder %s "
				% observed_powder.get_path(),
				"is CONSUMED, so button should not even be enabled")
