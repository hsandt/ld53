class_name Player
extends CharacterBody2D


@export var smoothing_node: Node2D
@export var animated_sprite_with_brightness_controller: AnimatedSprite2DBrightnessController

## Parent of smoke FX animated sprites
@export var smoke_fx_parent: Node2D

@export var first_smoke_fx_frame_desync: int = 2

@export var sled_slide_sfx_player: AudioStreamPlayer
@export var buff_sfx_player: AudioStreamPlayer
@export var debuff_slide_sfx_player: AudioStreamPlayer

@export var fx_hit_obstacle_prefab: PackedScene

@export var fx_hit_obstacle_anchor: Marker2D

@export var acceleration = 1000
@export var target_base_speed = 1000
@export var base_steer_speed = 500

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
## We can't @export it because of https://github.com/godotengine/g$Smoothing2Dodot/issues/62916
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
	&"speed": 0.0,
	&"steer_speed": 0.0
}

var _should_move: bool = false

func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")

	cargo.player = self

	# To make Y sort work, we have disabled global out on the Smoothing2D node,
	# but then we must move it outside the PlayerCharacter root and target it
	# from the outside
	# See https://github.com/lawnjelly/smoothing-addon#y-sort-in-2d

	# First, let's switch to global Z index if needed as reparent will break it
	# if PlayerCharacter has its own Z index != 0 and we use relative Z index
	if smoothing_node.z_as_relative:
		var global_z_index = Utils.get_absolute_z_index(smoothing_node)
		smoothing_node.z_as_relative = false
		smoothing_node.z_index = global_z_index

	# Second, let's explicitly target the Player Character as it won't be a
	# parent anymore
	smoothing_node.target = get_path()

	# Finally, reparent the smoothing node to outer node level
	# Since we are processing children in _ready, defer this to end of frame
	smoothing_node.reparent.call_deferred(in_game_manager.level)

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

	set_base_attribute(&"speed", 0)
	set_base_attribute(&"steer_speed", base_steer_speed)

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

	var previous_base_speed = get_base_attribute(&"speed")
	if previous_base_speed < target_base_speed:
		# Accelerate until top speed
		var new_base_speed = min(previous_base_speed + delta * acceleration, target_base_speed)
		set_base_attribute(&"speed", new_base_speed)

	# Compute current speed from base and any modifiers
	var velocity_x = _compute_current_attribute(&"speed")

	var velocity_y
	var vertical_input = Input.get_axis("up", "down")
	if vertical_input != 0.0:
		velocity_y = vertical_input * _compute_current_attribute(&"steer_speed")
	else:
		velocity_y = 0.0

	velocity = Vector2(velocity_x, velocity_y)
	move_and_slide()


func _compute_current_attribute(attribute_name: String):
	var modifier_values := cargo.get_attribute_modifier_factor_and_offset(attribute_name)
	var modifier_factor := modifier_values[0]
	var modifier_offset := modifier_values[1]

	return modifier_factor * get_base_attribute(attribute_name) + modifier_offset


func get_base_attribute(attribute_name: String) -> float:
	return current_base_attributes[attribute_name]


func set_base_attribute(attribute_name: String, value: float):
	assert(attribute_name in current_base_attributes,
		"[Player] set_base_attribute: unknown attribute %s. " % attribute_name)
	current_base_attributes[attribute_name] = value


## Pause all logical nodes (but not visual nodes)
func pause_logic():
	cargo.process_mode = Node.PROCESS_MODE_DISABLED


func resume_logic():
	cargo.process_mode = Node.PROCESS_MODE_INHERIT


func start_move():
	sled_slide_sfx_player.play()
	_should_move = true


func stop_move():
	sled_slide_sfx_player.stop()
	_should_move = false


func hurt(damage):
	# Flash for the duration set in Flash Timer
	animated_sprite_with_brightness_controller.set_brightness_for_duration(hurt_brightness)
	cargo.hurt(damage)
	_play_fx_hit_obstacle()


func _play_fx_hit_obstacle():
	# FX prefab includes SFX
	var fx_hit_obstacle = fx_hit_obstacle_prefab.instantiate()
	in_game_manager.level.add_child(fx_hit_obstacle)
	fx_hit_obstacle.global_position = fx_hit_obstacle_anchor.global_position
