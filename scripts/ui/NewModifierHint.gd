class_name NewModifierHint
extends Control


@export var new_modifier_header_label: Label
@export var new_modifier_name_label: Label


func fill_content(new_modifier: Modifier):
	new_modifier_name_label.text = new_modifier.description
