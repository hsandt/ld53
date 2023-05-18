extends Node2D


@onready var sfx_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready():
	_play_sfx()

func _play_sfx():
	sfx_player.play()

# Set time before disappearing on FreeTimer
# It must be at least as long as the SFX and the FX animation
# Note that we don't react to animation_finished at the moment
# so we don't auto-clear the last sprite, so we must add an empty frame
# at the end of each spriteframe animation
func _on_free_timer_timeout():
	queue_free()
