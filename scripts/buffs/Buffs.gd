extends Node


class Buff:
	var attribute: String
	var effect: String
	var value: float
	var probability: float #chance of being triggered
	var duration: float #in seconds
	var chain: Array #index of other buffs this object deals with.

var buff_stack = []

func _ready ():
	var speedup = Buff.new()
	speedup.attribute="speed"
	speedup.effect="multiplier"
	speedup.value=1.5
	speedup.probability=0.5 #50% chance of occuring
	speedup.duration=5.0 #5 seconds long

	buff_stack.append(speedup)
	#TODO read in the buff list from the spreadsheet (csv file most likely)  at this point

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
func add_if_roll(buff):
	if randf()<buff.probability:
		buff_stack.append(buff)
		#TODO handle chain effects here
		return true
	return false

func _process(delta):
	for i in len(buff_stack):
		buff_stack[i].duration-=delta
		if buff_stack[i].duration<0:
			#TODO handle detonation effects here
			buff_stack.remove_at(i)


