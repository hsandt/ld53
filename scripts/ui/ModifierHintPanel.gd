class_name ModifierHintPanel
extends Panel

@export var icon: TextureRect
@export var icon_active: Control
@export var icon_lock: TextureRect
@export var hint: Label


func _ready():
	assert(icon != null, "[ModifierHintPanel] icon is not set on %s" % get_path())
	assert(icon_lock != null, "[ModifierHintPanel] icon_lock is not set on %s" % get_path())
	assert(icon_active != null, "[ModifierHintPanel] icon_active is not set on %s" % get_path())
	assert(hint != null, "[ModifierHintPanel] hint is not set on %s" % get_path())


func show_icon(modifier: Modifier, active: bool):
	icon.visible = true
	icon.texture = modifier.icon_texture
	icon_active.visible = active

func hide_icon():
	icon.visible = false
	icon_active.visible = false

func show_hint_text(modifier: Modifier):
	hint.visible = true
	hint.text = modifier.description

func hide_hint_text():
	hint.visible = false

func set_lock_visible(visibility: bool):
	icon_lock.visible = visibility
