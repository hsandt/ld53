class_name ModifierHintPanel
extends Panel

@export var icon: TextureRect
@export var icon_lock: TextureRect
@export var hint: Label


func _ready():
	assert(icon != null, "[ModifierHintPanel] icon is not set on %s" % get_path())
	assert(icon_lock != null, "[ModifierHintPanel] icon_lock is not set on %s" % get_path())
	assert(hint != null, "[ModifierHintPanel] hint is not set on %s" % get_path())


func fill_content(modifier: Modifier, state: Enums.PowderState):
	icon.texture = modifier.icon_texture
	hint.text = modifier.description

	var locked = state == Enums.PowderState.SPARK_LOCKED
	icon_lock.visible = locked
