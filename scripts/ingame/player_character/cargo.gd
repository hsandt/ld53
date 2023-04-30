extends Node2D

@onready var buffs = get_node("../Buffs")

func hurt(_damage):
	for child in get_children():
		if child.modifier == null:
			push_error("[cargo] hurt: child '%s' has no modifier defined", child.get_path())
			continue

		buffs.add(child.modifier)
