extends Control


signal close

## Path to file containing credits in rich text
@export_file("*.txt") var credits_file_path: String

## Credits rich text label, dynamically filled with credits_file_path
@export var credits_label: RichTextLabel

# Inspired by follow_focus_center.gd
@export var animate = true
@export var transition_time = 0.2
@export var scroll_speed: float = 300.0
@export var scroll_increment: float = 40.0
@export var scroll_page_increment: float = 120.0

@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var back_button: Button = %BackButton

var scroll_container_content: Control

## Stored scroll value as workaround for rounding of scroll value preventing
## scrolling down by small increments
var stored_scroll_value: float


func _ready():
	assert(credits_label != null, "[credits_menu_controller] credits_label is not set on %s" % get_path())
	assert(scroll_container.get_child_count() == 1, "[credits_menu_controller] scroll_container at %s does not have exactly 1 child" % get_path())

	scroll_container_content = scroll_container.get_child(0)

	var text := load_text()
	credits_label.text = text.strip_edges(false, true)


func _unhandled_input(event):
	# Required check, as we only hide this menu, not disable it
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		accept_event()
		go_back()
		return

	var scroll_delta: float = 0.0
	if event.is_action_pressed("ui_page_up"):
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


func _process(delta):
	# Required check, as we only hide this menu, not disable it
	if not visible:
		return

	var current_scroll_speed: float = 0.0
	if Input.is_action_pressed(&"ui_up"):
		current_scroll_speed = -scroll_speed
	elif Input.is_action_pressed(&"ui_down"):
		current_scroll_speed = scroll_speed

	if current_scroll_speed != 0:
		# HACK: Store custom scroll value as workaround for rounding of scroll value preventing
		# scrolling down by small increments
		stored_scroll_value += current_scroll_speed * delta

		# HOTFIX for scroll_container.get_v_scroll_bar().max_value being incorrect
		# See https://godotengine.org/qa/111691/how-find-the-max-value-scroll_horizontal-scrollcontainer
		# and https://www.reddit.com/r/godot/comments/bu9wvc/anyone_know_how_to_get_scrollcontainers_scroll/
		var v_scroll_bar_max = max(0, scroll_container_content.size.y - scroll_container.size.y)
		stored_scroll_value = clamp(stored_scroll_value, 0.0, v_scroll_bar_max)

		# Then set scroll value using this safe custom value
		scroll_container.scroll_vertical = stored_scroll_value


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
	stored_scroll_value = 0.0
	back_button.grab_focus()


# Emits close signal and saves the options
func go_back():
	emit_signal("close")
