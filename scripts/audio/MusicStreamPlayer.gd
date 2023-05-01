extends AudioStreamPlayer


var music_bus_index: int
# Currently unused, but useful to tune parameters later
#var low_pass_effect: AudioEffectLowPassFilter


func _ready():
	music_bus_index = AudioServer.get_bus_index(&"Music")
#	low_pass_effect = AudioServer.get_bus_effect(music_bus_index, 0)


func _on_pause_menu_pause():
	# Low pass effect is at index 0 on Music bus
	AudioServer.set_bus_effect_enabled(music_bus_index, 0, true)


func _on_pause_menu_resume():
	AudioServer.set_bus_effect_enabled(music_bus_index, 0, false)
