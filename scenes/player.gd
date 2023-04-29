extends CharacterBody2D


@export var speed = 1000
@export var steer_speed = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#TODO placeholder looping
	if(position.x>1000):
		position.x=-1000

	position.x+=speed*delta

	if (position.y<5) and Input.is_action_pressed("down"):
		position.y+=steer_speed*delta
	if (position.y>-5) and Input.is_action_pressed("up"):
		position.y-=steer_speed*delta
