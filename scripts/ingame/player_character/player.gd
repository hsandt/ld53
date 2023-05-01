class_name Player
extends CharacterBody2D


@export var animated_sprite_with_brightness_controller: AnimatedSprite2DBrightnessController

#how quickly the player recovers from impacts to full speed
@export var powder = 100
@export var acceleration = 1000
@export var top_speed = 1000
var current_speed = top_speed
@export var steer_speed = 500

## Max motion
@export var half_extent_y = 500

## Brightness set when hurt
@export var hurt_brightness: float = 0.5

@onready var buffs: Buffs = $Buffs
@onready var cargo: Node2D = $cargo

var should_move: bool = false


func hurt(damage):
	powder -= damage
	# Flash for the duration set in Flash Timer
	animated_sprite_with_brightness_controller.set_brightness_for_duration(hurt_brightness)
	cargo.hurt(damage)

func _physics_process(delta):
	# proto UI
	$powder_bar.value = powder

	if not should_move:
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
