extends Control


signal close

## Path to file containing credits in rich text
@export_file("*.txt") var credits_file_path: String

## Credits rich text label, dynamically filled with credits_file_path
@export var credits_label: RichTextLabel

@onready var back_button: Button = %BackButton
@onready var scroll_container: GamepadScrollable = %ScrollContainer


func _ready():
	assert(credits_label != null, "[credits_menu_controller] credits_label is not set on %s" % get_path())

	var text := load_text()
	credits_label.text = text.strip_edges(false, true)


func _unhandled_input(event):
	# Required check, as we only hide this menu, not disable it
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		accept_event()
		go_back()
		get_viewport().set_input_as_handled()


func load_text() -> String:
	if credits_file_path == null or credits_file_path.is_empty():
		push_error("[credits_menu_controller] load_text: credits_file_path is not set")
		return ""

	if not FileAccess.file_exists(credits_file_path):
		push_error("[credits_menu_controller] load_text: no file at credits_file_path '%s'" %
			credits_file_path)
		return ""

	var file = FileAccess.open(credits_file_path, FileAccess.READ)
	var content = file.get_as_text()
	return content


# Called from outside initializes the options menu
func on_open():
	back_button.grab_focus()
	scroll_container.on_open()


# Emits close signal and saves the options
func go_back():
	emit_signal("close")
