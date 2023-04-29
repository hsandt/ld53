extends CharacterBody3D


var speed = 10
var steer_speed = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#TODO placeholder looping
	if(position.x>50):
		position.x=-50
	position.x+=speed*delta
	if (position.y<5) and Input.is_action_pressed("down"):
		position.z+=steer_speed*delta
	if (position.y>-5) and Input.is_action_pressed("up"):
		position.z-=steer_speed*delta
