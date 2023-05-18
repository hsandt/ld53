class_name PowderPanel
extends Panel


@export var spark_explosion_prefab: PackedScene
@export var consume_explosion_prefab: PackedScene

@export var spark_explosion_anchor: Marker2D
@export var consume_explosion_anchor: Marker2D

@export var animated_sprite: AnimatedSprite2D
@export var modifier_hint_panel: ModifierHintPanel

@onready var button: Button = %Button


var powder_state_to_animation := {
	Enums.PowderState.IDLE: &"idle",
	Enums.PowderState.SPARK: &"spark",
	Enums.PowderState.SPARK_LOCKED: &"spark_locked",
	Enums.PowderState.CONSUMED: &"consumed",
}

var observed_powder: Powder


func _ready():
	assert(spark_explosion_prefab != null, "[Powder] spark_explosion_prefab is not set on %s" % get_path())
	assert(consume_explosion_prefab != null, "[Powder] consume_explosion_prefab is not set on %s" % get_path())

	assert(spark_explosion_anchor != null, "[Powder] spark_explosion_anchor is not set on %s" % get_path())
	assert(consume_explosion_anchor != null, "[Powder] consume_explosion_anchor is not set on %s" % get_path())

	assert(animated_sprite, "animated_sprite is not set on %s" % get_path())
	assert(modifier_hint_panel != null, "[Powder] modifier_hint_panel is not set on %s" % get_path())

	hide_modifier_hint_panel()

	# Start disabled until state changes
	button.disabled = true

func register_observed_powder(powder: Powder):
	observed_powder = powder

func on_powder_state_changed(_previous_state: Enums.PowderState, new_state: Enums.PowderState):
	animated_sprite.animation = powder_state_to_animation[new_state]

	if new_state == Enums.PowderState.SPARK:
		_play_spark_explosion_feedback()
		show_modifier_hint_panel()
		button.disabled = false
	elif new_state == Enums.PowderState.SPARK_LOCKED:
		# Locked, so keep button disabled
		show_modifier_hint_panel()
	elif new_state == Enums.PowderState.CONSUMED:
		# After consume, cannot press button anymore
		button.disabled = true
		_play_consume_explosion_feedback()

		# There should always be a secondary modifier after Consume,
		# but in case we change design to allow empty secondary modifier
		if observed_powder.current_modifier != null:
			# Hint panel should already be shown from SPARK state, but call
			# this again to update content
			show_modifier_hint_panel()
		else:
			hide_modifier_hint_panel()

func _on_button_pressed():
	if observed_powder == null:
		return

	match observed_powder.state:
		Enums.PowderState.IDLE:
			return
		Enums.PowderState.SPARK:
			observed_powder.consume()
		Enums.PowderState.SPARK_LOCKED:
			return
		Enums.PowderState.CONSUMED:
			return


func _play_spark_explosion_feedback():
	var spark_explosion = spark_explosion_prefab.instantiate()
	get_parent().add_child(spark_explosion)
	spark_explosion.global_position = spark_explosion_anchor.global_position


func _play_consume_explosion_feedback():
	var consume_explosion = consume_explosion_prefab.instantiate()
	get_parent().add_child(consume_explosion)
	consume_explosion.global_position = consume_explosion_anchor.global_position


func show_modifier_hint_panel():
	assert(observed_powder.current_modifier != null,
		"[PowderPanel] show_modifier_hint_panel: no current modifier on observed_powder %s" %
		observed_powder.get_path())

	modifier_hint_panel.visible = true
	modifier_hint_panel.fill_content(observed_powder.current_modifier, observed_powder.state)


func hide_modifier_hint_panel():
	modifier_hint_panel.visible = false
