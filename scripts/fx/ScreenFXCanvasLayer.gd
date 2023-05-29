class_name ScreenFXCanvasLayer
extends CanvasLayer


@export var speed_lines_pfx: CPUParticles2D


func _ready():
	assert(speed_lines_pfx != null,
		"[ScreenFXCanvasLayer] speed_lines_pfx is not set on %s" % get_path())

	# Hide speed lines (in case they were emitting in scene for testing in editor)
	stop_speed_lines()


func is_playing_speed_lines():
	return speed_lines_pfx.emitting


## Show screen speed lines FX at given speed scale
func play_speed_lines(speed_scale: float):
	speed_lines_pfx.emitting = true
	speed_lines_pfx.speed_scale = speed_scale


## Hide screen speed lines FX
func stop_speed_lines():
	speed_lines_pfx.emitting = false
