class_name PowderPanel
extends Panel


@export var spark_explosion_prefab: PackedScene
@export var consume_explosion_prefab: PackedScene

@export var spark_explosion_anchor: Marker2D
@export var consume_explosion_anchor: Marker2D

@export var animated_sprite: AnimatedSprite2DWithOutline
@export var modifier_hint_panel: ModifierHintPanel

@onready var button: ButtonWithCustomCursor = %Button

@export var sprite_hover_outline_color: Color = Color(1.0, 1.0, 1.0, 0.5)
@export var sprite_hover_outline_thickness: float = 6.0
@export var sprite_focus_outline_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var sprite_focus_outline_thickness: float = 6.0


var powder_state_to_animation := {
	Enums.PowderState.IDLE: &"idle",
	Enums.PowderState.SPARK: &"spark",
	Enums.PowderState.SPARK_LOCKED: &"spark_locked",
	Enums.PowderState.CONSUMED: &"consumed",
}

var observed_powder: Powder

## True when mouse is hovering button (has entered, not exited)
var is_button_hovered: bool


func _ready():
	assert(spark_explosion_prefab != null, "[Powder] spark_explosion_prefab is not set on %s" % get_path())
	assert(consume_explosion_prefab != null, "[Powder] consume_explosion_prefab is not set on %s" % get_path())

	assert(spark_explosion_anchor != null, "[Powder] spark_explosion_anchor is not set on %s" % get_path())
	assert(consume_explosion_anchor != null, "[Powder] consume_explosion_anchor is not set on %s" % get_path())

	assert(animated_sprite, "animated_sprite is not set on %s" % get_path())
	assert(modifier_hint_panel != null, "[Powder] modifier_hint_panel is not set on %s" % get_path())

	# Wait for powder registration to show future icon
	hide_modifier_icon()
	hide_lock()
	hide_modifier_hint_panel()

	# Start disabled until state changes
	disable_interactions()

	is_button_hovered = false


func _process(_delta):
	# Focus has priority over hover in terms of feedback
	if not button.has_focus():
		# Update outline based on hover state
		# Doing this in _process is more reliable as it covers the case where
		# user keeps mouse over a keg and navigates with directional input:
		# the keg will still be outlined after navigation crosses hovered keg
		if is_button_hovered:
			animated_sprite.set_outline_color(sprite_hover_outline_color)
			animated_sprite.set_outline_thickness(sprite_hover_outline_thickness)
		else:
			animated_sprite.reset_outline_color()
			animated_sprite.reset_outline_thickness()


func enable_interactions():
	button.enable_interactions()

func disable_interactions():
	button.disable_interactions()

func register_observed_powder(powder: Powder):
	observed_powder = powder

	# Start showing just future modifier icon to give an idea to player what
	# may happen on Spark
	# Normally we only register when IDLE, else call below will assert
	show_future_modifier_icon()

func on_powder_state_changed(_previous_state: Enums.PowderState, new_state: Enums.PowderState):
	animated_sprite.animation = powder_state_to_animation[new_state]

	if new_state == Enums.PowderState.SPARK:
		_play_spark_explosion_feedback()
		show_current_modifier_icon()
		show_modifier_hint_panel()
		enable_interactions()
	elif new_state == Enums.PowderState.SPARK_LOCKED:
		# Locked, so keep button disabled
		show_current_modifier_icon()
		show_lock()
		show_modifier_hint_panel()
	elif new_state == Enums.PowderState.CONSUMED:
		# After consume, cannot press button anymore
		disable_interactions()
		_play_consume_explosion_feedback()

		# There should always be a secondary modifier after Consume,
		# but in case we change design to allow empty secondary modifier
		if observed_powder.current_modifier != null:
			# Hint panel should already be shown from SPARK state, but call
			# this again to update content
			show_current_modifier_icon()
			show_modifier_hint_panel()
		else:
			hide_modifier_icon()
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


func show_future_modifier_icon():
	assert(observed_powder.state == Enums.PowderState.IDLE,
		"[PowderPanel] show_future_modifier_icon: future modifier is only for IDLE state")
	# active: false
	modifier_hint_panel.show_icon(observed_powder.data.spark_debuff_modifier, false)


func show_current_modifier_icon():
	assert(observed_powder.state != Enums.PowderState.IDLE,
		"[PowderPanel] show_current_modifier_icon: future modifier is not for IDLE state")
	# active: true
	modifier_hint_panel.show_icon(observed_powder.current_modifier, true)


func hide_modifier_icon():
	modifier_hint_panel.hide_icon()


func show_lock():
	modifier_hint_panel.set_lock_visible(true)


func hide_lock():
	modifier_hint_panel.set_lock_visible(false)


func show_modifier_hint_panel():
	assert(observed_powder.current_modifier != null,
		"[PowderPanel] show_modifier_hint_panel: no current modifier on observed_powder %s" %
		observed_powder.get_path())

	modifier_hint_panel.visible = true
	modifier_hint_panel.show_hint_text(observed_powder.current_modifier)


func hide_modifier_hint_panel():
	modifier_hint_panel.visible = false


## Connected via signal in inspector
func _on_button_focus_entered():
	animated_sprite.set_outline_color(sprite_focus_outline_color)
	animated_sprite.set_outline_thickness(sprite_focus_outline_thickness)


## Connected via signal in inspector
func _on_button_focus_exited():
	animated_sprite.reset_outline_color()
	animated_sprite.reset_outline_thickness()


## Connected via signal in inspector
func _on_button_mouse_entered():
	is_button_hovered = true


## Connected via signal in inspector
func _on_button_mouse_exited():
	is_button_hovered = false
