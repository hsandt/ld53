class_name ButtonWithCustomCursor
extends Button


func _ready():
	_update_mouse_default_cursor_shape()

func enable_interactions():
	disabled = false
	_update_mouse_default_cursor_shape()

func disable_interactions():
	disabled = true
	_update_mouse_default_cursor_shape()

func _update_mouse_default_cursor_shape():
	mouse_default_cursor_shape = Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND
