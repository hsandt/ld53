class_name Buffs
extends Node2D

@onready var buff_scene = preload("res://scripts/buffs/buff.tscn")

#currently active
func get_attribute(name,baseline):
	for buff in get_children():
		if buff.modifier.attribute == name:
			match buff.modifier.effect:
				"multiplier":
					baseline*=buff.modifier.value
				"addition":
					baseline+=buff.modifier.value
	return baseline

func add_if_roll(modifier: Modifier):
	if randf()<modifier.probability:
		var b = buff_scene.instantiate()
		b.modifier=modifier
		b.position.y-=200+(100*len(get_children()))
		b.get_node("progress/duration").wait_time=b.modifier.duration
		add_child(b)

func add(modifier: Modifier):
	add_if_roll(modifier)
