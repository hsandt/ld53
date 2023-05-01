class_name Buffs
extends Node2D

@onready var buff_scene = preload("res://scripts/buffs/buff.tscn")


#@onready var base_powder= get_node("/root/Node2D2/CanvasLayer/HUD/powderpanel/HboxContainer")
@onready var base_powder= get_node("/root/Node2D2/CanvasLayer/HUD/powderpanel/HBoxContainer")
@onready var powderpanel1= get_node("/root/Node2D2/CanvasLayer/HUD/powderpanel/HBoxContainer/Powder Panel1")
@onready var powderpanel2= get_node("/root/Node2D2/CanvasLayer/HUD/powderpanel/HBoxContainer/Powder Panel2")
@onready var powderpanel3= get_node("/root/Node2D2/CanvasLayer/HUD/powderpanel/HBoxContainer/Powder Panel3")
@onready var powderpanel4= get_node("/root/Node2D2/CanvasLayer/HUD/powderpanel/HBoxContainer/Powder Panel4")
@onready var powderpanel5= get_node("/root/Node2D2/CanvasLayer/HUD/powderpanel/HBoxContainer/Powder Panel5")
@onready var powderpanel6= get_node("/root/Node2D2/CanvasLayer/HUD/powderpanel/HBoxContainer/Powder Panel6")

var bcount=0

var buffs = []
func _ready():
	print(base_powder)
	buffs.append(powderpanel1.get_node("buff"))
	buffs.append(powderpanel2.get_node("buff"))
	buffs.append(powderpanel3.get_node("buff"))
	buffs.append(powderpanel4.get_node("buff"))
	buffs.append(powderpanel5.get_node("buff"))
	buffs.append(powderpanel6.get_node("buff"))

#currently active
func get_attribute(name,baseline):
	for buff in buffs:
		if(buff.modifier == null):
			continue
		if buff.modifier.attribute == name:
			match buff.modifier.effect:
				"multiplier":
					baseline*=buff.modifier.value
				"addition":
					baseline+=buff.modifier.value
	return baseline

func add_if_roll(modifier: Modifier):
	if randf()<modifier.probability:
		buffs[bcount].activate(modifier)
		bcount+=1

func add(modifier: Modifier):
	add_if_roll(modifier)
