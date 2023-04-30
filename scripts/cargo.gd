extends Node2D

@onready var buffs = get_node("../Buffs")

func hurt(_damage):
	for child in get_children():
		buffs.add_from_index(child.buff_index)
