class_name Buffs
extends Node


#currently active
var buff_stack = []

func _ready ():
	pass


func get_attribute(name,baseline):
	for buff in buff_stack:
		if buff.attribute == name:
			match buff.effect:
				"multiplier":
					baseline*=buff.value
				"addition":
					baseline+=buff.value
	return baseline


#returns true if the buff passed its probability test and was added.
func add_if_roll(buff: Buff):
	if randf()<buff.probability:
		buff_stack.append(buff)
		#TODO handle chain effects here
		return true
	return false

func add(buff: Buff):
	add_if_roll(buff)

func _physics_process(delta):
	for i in len(buff_stack):
		if i>len(buff_stack): #FIXME wtf godot
			continue
		buff_stack[i].duration-=delta
		if buff_stack[i].duration<0:
			#TODO handle detonation effects here
			buff_stack.remove_at(i)


