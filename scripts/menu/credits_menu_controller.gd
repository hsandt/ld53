extends Control


signal close

## Path to file containing credits in rich text
@export_file("*.txt") var credits_file_path: String

## Credits rich text label, dynamically filled with credits_file_path
@export var credits_label: RichTextLabel

# Inspired by follow_focus_center.gd
@export var animate = true
@export var transition_time = 0.2
@export var scroll_increment: float = 40
@export var scroll_page_increment: float = 120

@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var back_button: Button = %BackButton


func _ready():
	assert(credits_label != null, "[credits_menu_controller] credits_label is not set on %s" % get_path())

	var text := load_text()
	credits_label.text = text.strip_edges(false, true)


func _unhandled_input(event):
	# Safety check
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		accept_event()
		go_back()
		return

	var scroll_delta: float = 0.0
	if event.is_action_pressed("ui_up"):
		scroll_delta = -scroll_increment
	elif event.is_action_pressed("ui_down"):
		scroll_delta = scroll_increment
	elif event.is_action_pressed("ui_page_up"):
		scroll_delta = -scroll_page_increment
	elif event.is_action_pressed("ui_page_down"):
		scroll_delta = scroll_page_increment

	if scroll_delta != 0:
		var scroll_destination := scroll_container.scroll_vertical + scroll_delta
		if animate:
			var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.tween_property(scroll_container, "scroll_vertical", scroll_destination, transition_time)
		else:
			scroll_container.scroll_vertical = scroll_destination

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
	scroll_container.scroll_vertical = 0.0
	back_button.grab_focus()


# Emits close signal and saves the options
func go_back():
	emit_signal("close")
