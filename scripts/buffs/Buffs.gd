class_name Buffs
extends Node

#currently active
var buff_stack = []

func get_attribute(name,baseline):
	for buff in buff_stack:
		if buff.attribute == name:
			match buff.effect:
				"multiplier":
					baseline*=buff.value
				"addition":
					baseline+=buff.value
	return baseline

func add_if_roll(buff: Buff):
	if randf()<buff.probability:
		buff_stack.append(buff)

func add(buff: Buff):
	add_if_roll(buff)

func _physics_process(delta):
	for i in range(buff_stack.size() -1 ,-1 ,-1):
		buff_stack[i].duration-=delta
		if buff_stack[i].duration<0:
			buff_stack.remove_at(i)
