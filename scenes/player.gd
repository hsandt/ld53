extends CharacterBody2D


#how quickly the player recovers from impacts to full speed
@export var powder = 100
@export var acceleration = 1000
@export var top_speed = 1000
var current_speed = top_speed
@export var steer_speed = 500

func hurt(damage):
	powder -= damage
	$flashbox.flash()
	current_speed*=0.5

func _process(delta):

	$powder_bar.value=powder

	if(current_speed < top_speed):
		current_speed+=delta*acceleration

	#TODO placeholder looping
	if(position.x>1500):
		position.x=-1500

	position.x+=current_speed*delta

	if (position.y<500) and Input.is_action_pressed("down"):
		position.y+=steer_speed*delta
	if (position.y>-500) and Input.is_action_pressed("up"):
		position.y-=steer_speed*delta
