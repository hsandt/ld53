extends Node2D

@onready var buffs = get_node("../Buffs")

func hurt(_damage):
	for child in get_children():
		if child.buff == null:
			push_error("[cargo] hurt: child '%s' has no buff defined", child.get_path())
			continue

		buffs.add(child.buff)
