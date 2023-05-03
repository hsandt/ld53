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
var _should_move: bool = false
var current_speed: float


func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")
	current_speed = top_speed


func hurt(damage):
	# Flash for the duration set in Flash Timer
	animated_sprite_with_brightness_controller.set_brightness_for_duration(hurt_brightness)
	cargo.hurt(damage)


func _physics_process(delta):
	if not _should_move:
		return

	if current_speed < top_speed:
		current_speed += delta * acceleration

	var velocity_x = buffs.get_attribute("speed", current_speed)

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


func start_move():
	sled_slide_sfx_player.play()
	_should_move = true

func stop_move():
	sled_slide_sfx_player.stop()
	_should_move = false
