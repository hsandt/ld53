class_name ButtonWithCustomCursor
extends Button


@export var sfx_click_player: AudioStreamPlayer


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

func _on_pressed():
	if sfx_click_player != null:
		sfx_click_player.play()
