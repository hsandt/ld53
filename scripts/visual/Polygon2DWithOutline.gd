# Adapted from kakoeimon's code based on twinpixel's suggestion to Godot4
# https://godotengine.org/qa/3963/is-it-possible-to-have-a-polygon2d-with-outline
@tool
extends Polygon2D

@export var OutLine: Color = Color(0,0,0):
	set = set_outline_color
@export var Width: float = 2.0:
	set = set_width

func _draw():
	var poly = get_polygon()
	for i in range(1 , poly.size()):
		draw_line(poly[i-1] , poly[i], OutLine , Width)
	draw_line(poly[poly.size() - 1] , poly[0], OutLine , Width)

func _process(_delta: float):
	queue_redraw()

## Renamed from set_color to avoid this error:
## > The method "set_color" overrides a method from native class "Polygon2D".
## > This won't be called by the engine and may not work as expected. (Warning treated as error.)
func set_outline_color(color):
	OutLine = color
	queue_redraw()

func set_width(new_width):
	Width = new_width
	queue_redraw()
