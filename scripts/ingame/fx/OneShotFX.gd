extends Node2D


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sfx_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready():
	_play_sfx()

func _play_sfx():
	sfx_player.play()


func _on_animated_sprite_2d_animation_finished():
	# Clear sprite at end of animation to avoid last sprite staying frozen
	animated_sprite.visible = false


# Set time before disappearing on FreeTimer
# It must be at least as long as the SFX and the FX animation
func _on_free_timer_timeout():
	queue_free()
