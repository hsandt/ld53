extends Control

@export var modifier: Modifier
@export var explosion_prefab: PackedScene
@onready var spark_button: Button = $spark_button

func activate(mod):
	visible=true
	$progress/duration.wait_time=mod.duration
	$progress/duration.start()
	$spark_loop_sfx.play()
	$spark_hit_sfx.play()
	modifier=mod
	assert(modifier != null,
		"[buff] on buff '%s', modifier is not defined" % get_path())
	assert(explosion_prefab != null,
		"[buff] on buff '%s', explosion_prefab is not defined" % get_path())

	if modifier.lucky == null and modifier.worsen == null:
		# no further modifier, no button
		spark_button.hide()
	$label.text=modifier.description
	if(len(modifier.icon_path)>1):
		$icon.texture=load("res://sprites/buff_icons/"+modifier.icon_path)

func _on_duration_timeout():
	# Timeout: explode without the burst effect
	_explode()

func _on_spark_button_pressed():
	# Burst: explode with the burst effect (get lucky or worsen)

	$spark_button/ui_click_sfx.play()

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
		activate(modifier.lucky)
	else:
		$debuff_sfx.play()
		activate(modifier.worsen)

	_explode()


func _explode():
	_play_explosion_feedback()


func _play_explosion_feedback():
	var explosion = explosion_prefab.instantiate()
	get_tree().root.add_child(explosion)
