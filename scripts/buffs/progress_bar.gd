extends TextureProgressBar

func _process(_delta):
	value=100*($duration.time_left/$duration.wait_time)
