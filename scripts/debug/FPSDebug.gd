extends Control


## Label displaying current fps
@export var label_fps_number: Label


func _ready():
	assert(label_fps_number, "label_fps_number is not set on %s" % get_path())


func _physics_process(_delta):
	label_fps_number.text = "%d" % Engine.get_frames_per_second()
