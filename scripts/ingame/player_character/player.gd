class_name Player
extends CharacterBody2D


@export var animated_sprite_with_brightness_controller: AnimatedSprite2DBrightnessController
@export var sled_slide_sfx_player: AudioStreamPlayer

@export var acceleration = 1000
@export var top_speed = 1000
@export var steer_speed = 500

## Max motion
@export var half_extent_y = 500

## Brightness set when hurt
@export var hurt_brightness: float = 0.5

@onready var buffs: Buffs = $Buffs
@onready var cargo: Cargo = $cargo

var in_game_manager: InGameManager

var current_base_attributes := {
	"speed": 0.0
}

var _should_move: bool = false

func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")
	set_base_attribute("current_speed", top_speed)


func _physics_process(delta):
	if not _should_move:
		return

	var previous_base_speed = get_base_attribute("speed")
	if previous_base_speed < top_speed:
		# Accelerate until top speed
		var new_base_speed = min(previous_base_speed + delta * acceleration, top_speed)
		set_base_attribute("speed", new_base_speed)

	# Compute current speed from base and any modifiers
	var velocity_x = _compute_current_attribute("speed")

	var velocity_y = 0
	if Input.is_action_pressed("down"):
		velocity_y += $Buffs.get_attribute("steer_speed",steer_speed)
	if Input.is_action_pressed("up"):
		velocity_y -= $Buffs.get_attribute("steer_speed",steer_speed)

	velocity = Vector2(velocity_x, velocity_y)
	move_and_slide()

	# top limit
	if position.y < -half_extent_y:
		position.y  = -half_extent_y

	# bottom limit
	if position.y > half_extent_y:
		position.y = half_extent_y


func _compute_current_attribute(attribute_name: String):
	var modifier_values := cargo.get_attribute_modifier_factor_and_offset("speed")
	var modifier_factor := modifier_values[0]
	var modifier_offset := modifier_values[1]

	return modifier_factor * get_base_attribute(attribute_name) + modifier_offset


func get_base_attribute(attribute_name: String) -> float:
	return current_base_attributes[attribute_name]


func set_base_attribute(attribute_name: String, value: float):
	current_base_attributes[attribute_name] = value


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
