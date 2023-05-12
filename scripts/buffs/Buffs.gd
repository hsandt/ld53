class_name Buffs
extends Node2D

@onready var buff_scene = preload("res://scripts/buffs/buff.tscn")

var in_game_manager: InGameManager
var bcount=0
var buffs = []

func _ready():
	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")

	if in_game_manager == null:
		# we must be playing scene player character scene individually for
		# testing
		return

	var base_powder = in_game_manager.hud.powders_panel.hbox
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

func add(modifier: Modifier):
	# modulo for safety, would need something cleaner
	bcount = bcount % buffs.size()
	buffs[bcount].activate(modifier)
	bcount+=1
