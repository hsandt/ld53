extends CharacterBody2D


@export var animated_sprite_with_brightness_controller: AnimatedSprite2DBrightnessController

#how quickly the player recovers from impacts to full speed
@export var powder = 100
@export var acceleration = 1000
@export var top_speed = 1000
var current_speed = top_speed
@export var steer_speed = 500

## Brightness set when hurt
@export var hurt_brightness: float = 0.5


func hurt(damage):
	powder -= damage
	# Flash for the duration set in Flash Timer
	animated_sprite_with_brightness_controller.set_brightness_for_duration(hurt_brightness)
	current_speed*=0.5
	$cargo.hurt(damage)

func _process(delta):

	$powder_bar.value=powder

	if(current_speed < top_speed):
		current_speed+=delta*acceleration

	#TODO placeholder looping
	if(position.x>1500):
		position.x=-1500

	position.x+=$Buffs.get_attribute("speed",current_speed)*delta

	if (position.y<500) and Input.is_action_pressed("down"):
		position.y+=steer_speed*delta
	if (position.y>-500) and Input.is_action_pressed("up"):
		position.y-=steer_speed*delta
