extends Polygon2D


func flash():
	visible=true
	$Timer.start()

func timeout():
	visible=false
