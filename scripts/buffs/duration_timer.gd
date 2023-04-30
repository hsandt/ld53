extends Timer

func _process(delta):
	print($progress_bar.value)
	$progress_bar.value=100*(time_left/wait_time)
