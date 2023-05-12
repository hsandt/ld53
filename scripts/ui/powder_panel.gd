class_name PowderPanel
extends Panel


@export var explosion_regular_prefab: PackedScene

@export var animated_sprite: AnimatedSprite2D
@export var explosion_anchor: Marker2D
@export var modifier_hint_panel: ModifierHintPanel

@onready var button: Button = %Button


var powder_state_to_animation := {
	Enums.PowderState.IDLE: &"idle",
	Enums.PowderState.SPARK: &"spark",
	Enums.PowderState.CONSUMED: &"consumed",
}

var observed_powder: Powder


func _ready():
	assert(explosion_regular_prefab != null, "[Powder] explosion_regular_prefab is not set on %s" % get_path())

	assert(animated_sprite, "animated_sprite is not set on %s" % get_path())
	assert(explosion_anchor != null, "[Powder] explosion_anchor is not set on %s" % get_path())
	assert(modifier_hint_panel != null, "[Powder] modifier_hint_panel is not set on %s" % get_path())

	hide_modifier_hint_panel()

func register_observed_powder(powder: Powder):
	observed_powder = powder

func on_powder_state_changed(_previous_state: Enums.PowderState, new_state: Enums.PowderState):
	animated_sprite.animation = powder_state_to_animation[new_state]

	if new_state == Enums.PowderState.SPARK:
		show_modifier_hint_panel()
	elif new_state == Enums.PowderState.CONSUMED:
		_play_explosion_feedback()

		# There should always be a secondary modifier after Consume,
		# but in case we change design to allow empty secondary modifier
		if observed_powder.current_modifier != null:
			show_modifier_hint_panel()

func _on_button_pressed():
	if observed_powder == null:
		return

	match observed_powder.state:
		Enums.PowderState.IDLE:
			return
		Enums.PowderState.SPARK:
			observed_powder.consume()
		Enums.PowderState.CONSUMED:
			return


func _play_explosion_feedback():
	var explosion_regular = explosion_regular_prefab.instantiate()
	get_parent().add_child(explosion_regular)
	explosion_regular.global_position = explosion_anchor.global_position


func show_modifier_hint_panel():
	assert(observed_powder.current_modifier != null,
		"[PowderPanel] show_modifier_hint_panel: no current modifier on observed_powder %s" %
		observed_powder.get_path())

	modifier_hint_panel.visible = true
	modifier_hint_panel.fill_content(observed_powder.current_modifier)


func hide_modifier_hint_panel():
	modifier_hint_panel.visible = false

