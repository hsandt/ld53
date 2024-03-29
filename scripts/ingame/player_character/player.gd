class_name Player
extends CharacterBody2D


## Signal sent when attribute changed (via base or modifier value)
signal attribute_changed(attribute_name: StringName, new_value: float)

## Signal sent when boost level changes
signal boost_level_changed(new_level: int)

@export var smoothing_node: Node2D
@export var animated_sprite_with_brightness_controller: AnimatedSprite2DBrightnessController

## Parent of smoke FX animated sprites
@export var smoke_fx_parent: Node2D

## Boost FX
@export var boost_fx: OneShotFX

@export var first_smoke_fx_frame_desync: int = 2

# Local HUD
@export var boost_level_indicator: BoostLevelIndicator

@export var sled_slide_sfx_player: AudioStreamPlayer
@export var annoying_sounds_sfx_player: AudioStreamPlayer
@export var buff_sfx_player: AudioStreamPlayer
@export var debuff_slide_sfx_player: AudioStreamPlayer

@export var fx_hit_obstacle_prefab: PackedScene

@export var fx_hit_obstacle_anchor: Marker2D
@export var speech_bubble_queue_anchor: Marker2D

@export var base_speed = 1000.0
@export var boost_max_level = 5
@export var extra_speed_per_boost_level = 200.0
@export var boost_abs_extra_lookahead_distance = 200.0
@export var boost_extra_lookahead_duration_before_dampen = 1.0

@export var acceleration = 1000.0
@export var deceleration = 1000.0

@export var base_steer_speed = 500.0

## Velocity X at which animation speed scale should be 1
@export_range(1.0, 2000.0) var animation_reference_velocity_x: float = 1000.0

## Velocity X at which smoke FX will start to appear
@export_range(0.0, 1.0) var smoke_fx_min_unclamped_speed_ratio: float = 0.5

## Smoke FX min scale factor, used at smoke_fx_min_velocity_x
## Note that this doesn't include the natural scale used when important
## hi-res sprites (see smoke_fx_initial_scale)
@export_range(0.0, 1.0) var smoke_fx_min_scale_factor: float = 0.5

## Smoke FX max scale factor that can be reached at high speed
## This allows even bigger FX above reference speed
## Note that this doesn't include the natural scale used when important
## hi-res sprites (see smoke_fx_initial_scale)
@export_range(1.0, 2.0) var smoke_fx_max_scale_factor: float = 1.5

## Max animated speed scale allowed even at high speed
@export_range(1.0, 10.0) var smoke_fx_max_speed_scale: float = 5.0

## Velocity X at which speed lines should start playing, also reference for scaling
## (speed scale is 1 at this value)
@export_range(1.0, 3000.0) var speed_lines_min_speed: float = 1500.0

## Brightness set when hurt
@export var hurt_brightness: float = 0.5

@onready var cargo: Cargo = $cargo

var in_game_manager: InGameManager

## Derived from smoke_fx_parent
## We can't @export it because of https://github.com/godotengine/godot/issues/62916
## until Godot 4.1
var smoke_fx_animated_sprites: Array[AnimatedSprite2D]

## Scale set for smoke FX in editor. Reference scale.
## Should be 0.5 for 4K sprites @ 1080p
var smoke_fx_initial_scale: float = 0.0

## Base attributes dictionary
var current_base_attributes := {
	# Do not set these values to exported members as default values here,
	# because we must wait for initialization to be completed, so do it in
	# _ready instead
	# For attributes with a trivial base value like 0 or 1, you can set it here
	# Horizontal speed
	# Base value will be set in _ready from export value
	&"speed": 0.0,
	# Vertical speed
	# Base value will be set in _ready from export value
	&"steer_speed": 0.0,
	# Time it takes to reach target steer speed
	&"steer_accel_delay": 0.0,
	# Time it takes to reach steer speed = 0 from max steer speed
	&"steer_decel_delay": 0.0,
	# Meta-modifier: contributes to steer_accel_delay and steer_decel_delay
	&"steer_delay": 0.0,
	# Factor applied to received damage
	&"damage_factor": 1.0,
	# Additional probability to trigger lucky modifier on next consume
	# (if negative, increase probability to trigger worsen modifier)
	# Final probability is clamped
	&"next_consume_lucky_probability_offset": 0.0,
	# On damage, each powder keg has a certain probability to receive
	# no damage at all
	&"individual_powder_immunity_probability": 0.0,
	# On powder burst, each powder keg has a certain probability to get locked,
	# preventing future consume
	&"individual_powder_lock_probability": 0.0,
	# Controls camera shake intensity
	&"camera_shake_intensity": 0.0,
	# Controls how much to play annoying sounds
	&"annoying_sounds_intensity": 0.0,
	# Alpha transparency of progress bar
	&"progress_bar_visibility": 1.0,
	# If true, show big obstacles on level progress bar
	# Boolean attribute: 0 for false, 1 for true
	&"progress_bar_show_big_obstacles": 0.0,
	# Number of seconds of interval between progress bar updates
	&"progress_bar_lag": 0.0,
	# Alpha transparency of race timer
	&"race_timer_visibility": 1.0,
}

var _should_move: bool = false
var current_boost_level: int = 0
var _is_logic_only_paused: bool = false

# CHEAT
var god_mode_enabled: bool = false


func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")

	cargo.player = self

	for child in smoke_fx_parent.get_children():
		var animated_sprite = child as AnimatedSprite2D
		if animated_sprite:
			smoke_fx_animated_sprites.append(animated_sprite)
			if smoke_fx_initial_scale == 0.0:
				# First FX defines the scale (we assume scale.x == scale.y)
				smoke_fx_initial_scale = animated_sprite.scale.x
			else:
				assert(smoke_fx_initial_scale == animated_sprite.scale.x,
					"[Player] Expected both smoke FX to have same scale")
		else:
			push_error("[Player] Expected child %s to be an AnimatedSprite2D" %
				child.get_path())

	# Set base attribute for attributes that have an exported base value
	set_base_attribute(&"speed", base_speed)
	set_base_attribute(&"steer_speed", base_steer_speed)

	# Setup local HUD
	boost_level_indicator.setup(current_boost_level, boost_max_level)


func _process(_delta):
	# Play animations faster when character moves faster than reference speed, and vice-versa
	var unclamped_speed_ratio = velocity.x / animation_reference_velocity_x
	animated_sprite_with_brightness_controller.speed_scale = unclamped_speed_ratio

	# Smoke FX are a bit special, don't show them at all at low speed
	if unclamped_speed_ratio < smoke_fx_min_unclamped_speed_ratio:
		if smoke_fx_parent.visible:
			smoke_fx_parent.visible = false
	else:
		if not smoke_fx_parent.visible:
			smoke_fx_parent.visible = true
			# Offset one of the FX for desync
			smoke_fx_animated_sprites[0].frame = first_smoke_fx_frame_desync

		# Calculate scale based on speed
		var scale_factor: float
		if unclamped_speed_ratio <= 1:
			# Remap so min speed matches min scale, reaches 1 at ref speed
			scale_factor = remap(unclamped_speed_ratio,
				smoke_fx_min_unclamped_speed_ratio, 1.0,
				smoke_fx_min_scale_factor, 1.0)
		else:
			# Above ref speed, just scale until max scale factor
			scale_factor = min(unclamped_speed_ratio, smoke_fx_max_scale_factor)

		var smoke_fx_scale = scale_factor * smoke_fx_initial_scale

		# When visible, apply speed scale as usual, but also scale
		for smoke_fx_animated_sprite in smoke_fx_animated_sprites:
			smoke_fx_animated_sprite.speed_scale = min(unclamped_speed_ratio, smoke_fx_max_speed_scale)
			smoke_fx_animated_sprite.scale = smoke_fx_scale * Vector2.ONE

	# Speed lines
	var screen_fx_canvas_layer = in_game_manager.screen_fx_canvas_layer

	var unclamped_speed_lines_speed_ratio = velocity.x / speed_lines_min_speed
	if unclamped_speed_lines_speed_ratio >= 1:
		# If already playing, this will update speed
		screen_fx_canvas_layer.play_speed_lines(unclamped_speed_lines_speed_ratio)
	else:
		if screen_fx_canvas_layer.is_playing_speed_lines():
			screen_fx_canvas_layer.stop_speed_lines()


func _physics_process(delta):
	if not _should_move:
		return

	var velocity_x := velocity.x

	# Compute target speed including modifiers
	var target_speed = compute_current_attribute(&"speed")
	if velocity_x < target_speed:
		# Accelerate toward target speed
		velocity_x = move_toward(velocity_x, target_speed,
			delta * acceleration)
	elif velocity_x > target_speed:
		# Decelerate toward target speed
		velocity_x = move_toward(velocity_x, target_speed,
			delta * deceleration)

	var velocity_y := velocity.y
	var vertical_input = Input.get_axis("up", "down")
	var max_steer_speed = compute_current_attribute(&"steer_speed")

	if vertical_input != 0.0:
		var target_velocity_y = vertical_input * max_steer_speed

		var total_steer_accel_delay = compute_current_attribute(&"steer_accel_delay") + \
			compute_current_attribute(&"steer_delay")
		if total_steer_accel_delay > 0:
			# Accel based on current delay and max steer speed
			# (so we are not too slow when max steer speed increases)
			var steer_acceleration = max_steer_speed / total_steer_accel_delay
			velocity_y = move_toward(velocity_y, target_velocity_y, steer_acceleration * delta)
		else:
			# Instant
			velocity_y = target_velocity_y
	else:
		var total_steer_decel_delay = compute_current_attribute(&"steer_decel_delay") + \
			compute_current_attribute(&"steer_delay")
		if total_steer_decel_delay > 0:
			# Decel based on current decel delay and max steer speed (since it
			# tells us how much to change speed when decelerating from max speed
			# to full stop)
			var steer_deceleration = max_steer_speed / total_steer_decel_delay
			velocity_y = move_toward(velocity_y, 0.0, steer_deceleration * delta)
		else:
			# Instant
			velocity_y = 0.0

	# Apply vertical and horizontal motion separately to avoid diagonal moving
	# slide against a wall to add extra contribution to horizontal motion

	if velocity_y != 0.0:
		velocity = velocity_y * Vector2.DOWN
		move_and_slide()

	if velocity_x != 0.0:
		velocity = velocity_x * Vector2.RIGHT
		move_and_slide()

	# HACK to make sure velocity is correct when processed next frame
	# (for accel/decel) and in other scripts (like speed lines FX)
	# since the split move_and_slide above doesn't give the correct velocity
	velocity = Vector2(velocity_x, velocity_y)


func _unhandled_input(event):
	if not _is_logic_only_paused:
		if event.is_action_pressed(&"boost"):
			try_boost()


## Pause logic and visual
func pause():
	process_mode = Node.PROCESS_MODE_DISABLED
	# Remember smoothing_node has been reparented, so pause it too
	smoothing_node.process_mode = Node.PROCESS_MODE_DISABLED


func resume():
	process_mode = Node.PROCESS_MODE_INHERIT
	smoothing_node.process_mode = Node.PROCESS_MODE_INHERIT


## Pause all logical nodes (but not visual nodes)
func pause_logic():
	cargo.process_mode = Node.PROCESS_MODE_DISABLED
	# Flag is useful to prevent actions during Tutorial phase
	_is_logic_only_paused = true


func resume_logic():
	cargo.process_mode = Node.PROCESS_MODE_INHERIT
	_is_logic_only_paused = false


func compute_current_attribute(attribute_name: StringName) -> float:
	var modifier_values := cargo.get_attribute_modifier_factor_and_offset(attribute_name)
	var modifier_factor := modifier_values[0]
	var modifier_offset := modifier_values[1]

	return modifier_factor * get_base_attribute(attribute_name) + modifier_offset


func get_base_attribute(attribute_name: StringName) -> float:
	assert(attribute_name in current_base_attributes,
		"[Player] get_base_attribute: unknown attribute '%s'. " % attribute_name)
	return current_base_attributes[attribute_name]


func set_base_attribute(attribute_name: StringName, value: float):
	assert(attribute_name in current_base_attributes,
		"[Player] set_base_attribute: unknown attribute '%s'. " % attribute_name)
	current_base_attributes[attribute_name] = value
	_notify_attribute_changed(attribute_name)


## Called *after* modifier was actually changed (store previous modifier
## and pass it as removed_modifier)
func on_modifiers_changed(removed_modifier: Modifier, added_modifier: Modifier):
	if removed_modifier != null:
		# Some modifier removed, its associated attribute must have changed
		# Notify this
		_notify_attribute_changed(removed_modifier.attribute)
	if added_modifier != null and \
			(removed_modifier == null or added_modifier.attribute != removed_modifier.attribute):
		# Some modifier added, with a different attribute than the removed one
		# (or there was no removed one so it's obviously different),
		# so also notify this attribute value change
		_notify_attribute_changed(added_modifier.attribute)


## Call this to notify all entities of attribute change,
## including self
func _notify_attribute_changed(attribute_name: StringName):
	var new_value = compute_current_attribute(attribute_name)

	# Direct call is simpler than connecting self method
	_on_attribute_changed(attribute_name, new_value)
	attribute_changed.emit(attribute_name, new_value)


## This handles attribute change directly on self and is called directly in
## _notify_attribute_changed so we don't have to connect it to attribute_changed
## signal
func _on_attribute_changed(attribute_name: StringName, new_value: float):
	if attribute_name == &"annoying_sounds_intensity":
		if new_value > 0.0:
			_start_annoying_sounds(new_value)
		else:
			_stop_annoying_sounds()


func start_move():
	sled_slide_sfx_player.play()
	_should_move = true


func stop_move():
	sled_slide_sfx_player.stop()
	_should_move = false


func notify_boost_level_changed():
	# For self, update base speed
	set_base_attribute(&"speed",
		base_speed + extra_speed_per_boost_level * current_boost_level)

	# For others, emit signal
	boost_level_changed.emit(current_boost_level)

func try_boost():
	if current_boost_level < boost_max_level:
		current_boost_level += 1
		_play_boost_feedback()
		notify_boost_level_changed()

func try_decrement_boost_level():
	if current_boost_level > 0:
		current_boost_level -= 1
		notify_boost_level_changed()


func hurt(damage: float):
	if god_mode_enabled:
		return

	# Flash for the duration set in Flash Timer
	animated_sprite_with_brightness_controller.set_brightness_for_duration(hurt_brightness)
	cargo.hurt(damage)
	_play_fx_hit_obstacle()
	try_decrement_boost_level()


func toggle_god_mode_enabled():
	god_mode_enabled = not god_mode_enabled
	# remember animated sprite is on reparented smoothing_node
	# and for some reason smoothing_node.modulate doesn't affect the sprite
	# also we use animated_sprite_with_brightness_controller.modulate,
	# so set self_modulate instead
	animated_sprite_with_brightness_controller.self_modulate = Color("#ffff41") if god_mode_enabled else Color.WHITE


func try_start_success_sequence():
	if GameManager.game_phase != Enums.GamePhase.RACING:
		return

	in_game_manager.enter_success_phase()

	# TODO: play the happy animation here


func try_start_failure_sequence():
	if GameManager.game_phase != Enums.GamePhase.RACING:
		return

	in_game_manager.enter_failure_phase()

	# TODO: play the crash animation here


func _play_fx_hit_obstacle():
	# FX prefab includes SFX
	var fx_hit_obstacle = fx_hit_obstacle_prefab.instantiate()
	in_game_manager.level.add_child(fx_hit_obstacle)
	fx_hit_obstacle.global_position = fx_hit_obstacle_anchor.global_position


func _play_boost_feedback():
	# FX
	_play_fx_boost()

	# Camera
	# Remember to oppose sign to make camera go more backward so we have the impression
	# that player character goes more forward
	in_game_manager.scrolling_center.set_extra_lookahead_distance_with_dampen(
		-boost_abs_extra_lookahead_distance, boost_extra_lookahead_duration_before_dampen)

func _play_fx_boost():
	# Unlike FX Hit Obstacle, FX Boost is reusable, so it's prepared
	# in the scene and we just call play when we need it
	# FX prefab includes SFX
	boost_fx.play()


func _start_annoying_sounds(intensity: float):
	# Safeguard against bad values to avoid crazy volumes
	intensity = min(intensity, 1.0)
	annoying_sounds_sfx_player.volume_db = linear_to_db(intensity)
	annoying_sounds_sfx_player.play()


func _stop_annoying_sounds():
	annoying_sounds_sfx_player.stop()
