class_name ModifierHintPanel
extends Panel

@export var icon: TextureRect
@export var hint: Label


func _ready():
	assert(icon != null, "[ModifierHintPanel] icon is not set on %s" % get_path())
	assert(hint != null, "[ModifierHintPanel] hint is not set on %s" % get_path())


func fill_content(modifier: Modifier):
	icon.texture = modifier.icon_texture
	hint.text = modifier.description
