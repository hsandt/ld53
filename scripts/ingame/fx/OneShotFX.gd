class_name OneShotFX
extends Node2D
## Script to place on one-shot FX
## Two types are supported:
## - consumed FX: autoplay = true, a free timer is connected to auto-free
##                at the end of animation and SFX
##                Instantiate it when you want to play the FX
## - reusable FX: autoplay = false, no free timer
##                Prepare it in advance in the scene (or via code if you
##                don't know exactly how many and where you need them),
##                then call `play` when you want to play the FX


## If true, play animation and any SFX as soon as this node is instantiated
## If AnimatedSprite2D has set its own autoplay animation key, it will be used
## over any animation set in inspector.
## For reusable FX, set this to false and call `play` manually.
@export var autoplay: bool = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sfx_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready():
	if autoplay:
		# Note that if animated_sprite.autoplay is already set,
		# we only need to play SFX, but to cover more cases we
		# just play everything
		# animated_sprite.autoplay is still useful if multiple animations
		# are available and we want to pick a specific one to play
		play()
	else:
		animated_sprite.visible = false


func _play_sfx_if_any():
	if sfx_player.stream:
		sfx_player.play()


func play():
	# Show animated sprite in case it was hidden
	animated_sprite.visible = true

	# Stop any animation first to make sure we play it from the start
	animated_sprite.stop()
	# Note that we rely on either the animation set in inspector, or the
	# autoplay animation set in the SpriteFrames window if any, to decide
	# which animation to play. In most cases though, there is only one,
	# "default"
	animated_sprite.play()

	_play_sfx_if_any()


## Connected via signal from $AnimatedSprite2D in inspector,
func _on_animated_sprite_2d_animation_finished():
	# Clear sprite at end of animation to avoid last sprite staying frozen
	animated_sprite.visible = false


## Connected via signal from some FreeTimer in inspector,
## if you want FX to auto-free at the end of animation and SFX
## You must set timer Wait Time to a duration at least as long as the max
## of the animation length and the SFX duration
## If the FX is meant to be reused, do not connect this
func _on_free_timer_timeout():
	queue_free()
