class_name Buffs
extends Node2D

@onready var buff_scene = preload("res://scripts/buffs/buff.tscn")

var in_game_manager: InGameManager
var bcount=0
var buffs = []

func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")
	var base_powder = in_game_manager.hud.powder_panel.hbox
	var powderpanel1 = base_powder.get_child(0)
	var powderpanel2 = base_powder.get_child(1)
	var powderpanel3 = base_powder.get_child(2)
	var powderpanel4 = base_powder.get_child(3)
	var powderpanel5 = base_powder.get_child(4)
	var powderpanel6 = base_powder.get_child(5)

	buffs.append(powderpanel1.get_node("buff"))
	buffs.append(powderpanel2.get_node("buff"))
	buffs.append(powderpanel3.get_node("buff"))
	buffs.append(powderpanel4.get_node("buff"))
	buffs.append(powderpanel5.get_node("buff"))
	buffs.append(powderpanel6.get_node("buff"))

#currently active
func get_attribute(attribute_name,baseline):
	for buff in buffs:
		if(buff.modifier == null):
			continue
		if buff.modifier.attribute == attribute_name:
			match buff.modifier.effect:
				"multiplier":
					baseline*=buff.modifier.value
				"addition":
					baseline+=buff.modifier.value
	return baseline

func add_if_roll(modifier: Modifier):
	if randf()<modifier.probability:
		# modulo for safety, would need something cleaner
		bcount = bcount % buffs.size()
		buffs[bcount].activate(modifier)
		bcount+=1

func add(modifier: Modifier):
	add_if_roll(modifier)
