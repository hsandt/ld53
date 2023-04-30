extends Node


# BUG: circular dependency makes it always null, even when assigned
## Scene loaded when starting the game
#@export var first_scene: PackedScene
# workaround
@export_file("*.tscn") var first_scene_path: String
var first_scene: PackedScene


func _ready():
	first_scene = load(first_scene_path)
	assert(first_scene_path != null or first_scene_path.is_empty(),
		"[InGameManager] first_scene_path is not set on %s" % get_path())
	assert(first_scene != null,
		"[InGameManager] first_scene is not set on %s" % get_path())


# BUG: doesn't work, even with just _input
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed(&"restart"):
		SceneManager.change_scene(first_scene)


# WORKAROUND
func _process(delta):
	if Input.is_action_just_pressed(&"restart"):
		# and while we're at it, let's cut the dep by reloading current scene
		# this could be moved to AppManager
		get_tree().reload_current_scene()
