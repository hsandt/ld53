extends AudioStreamPlayer


@export var result_audio_stream_success: AudioStream
@export var result_audio_stream_failure: AudioStream


func _ready():
	if GameManager.game_phase == Enums.GamePhase.SUCCESS:
		stream = result_audio_stream_success
	else:
		stream = result_audio_stream_failure
	play()
