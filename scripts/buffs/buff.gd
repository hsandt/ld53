extends Control

@export var modifier: Modifier
@onready var spark_button: Button = $spark_button

func _ready():
	assert(modifier != null,
		"[buff] on buff '%s', modifier is not defined" % get_path())

	if modifier.lucky == null and modifier.worsen == null:
		# no further modifier, no button
		spark_button.hide()

func _on_duration_timeout():
	queue_free()

func _on_spark_button_pressed():
	$spark_button/ui_click_sfx.play()
	var buffs = get_parent()

	if modifier.lucky == null and modifier.worsen == null:
		push_error("[buff] button should not even be visible")
		return

	var trigger_lucky_effect: bool

	if modifier.lucky == null:
		# only worsen, so trigger worsen
		trigger_lucky_effect = false
	elif modifier.worsen == null:
		# only lucky, so trigger lucky
		trigger_lucky_effect = true
	else:
		# both exist, so it's random
		trigger_lucky_effect = randf() < 0.5

	if trigger_lucky_effect:
		$buff_sfx.play()
		buffs.add(modifier.lucky)
	else:
		$debuff_sfx.play()
		buffs.add(modifier.worsen)

