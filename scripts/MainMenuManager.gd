extends Node


## Scene loaded when starting the game
@export var first_scene: PackedScene

## Speed factor for initial fade in animation
@export var initial_fade_in_speed: float = 1.0

## Speed factor for start game fade out animation
@export var start_game_fade_out_speed: float = 1.0

## Speed factor for start game fade in animation
@export var start_game_fade_in_speed: float = 1.0


func _ready():
	assert(first_scene != null, "[MainMenuManager] first_scene is not set on %s" % get_path())

	# Disable input during fade in
	_set_disable_input(true)
	await TransitionScreen.fade_in_async(initial_fade_in_speed)
	_set_disable_input(false)


func _on_main_menu_start_game_pressed():
	# Disable input during transition
	_set_disable_input(true)
	await SceneManager.change_scene_with_fade_async(first_scene,
		start_game_fade_out_speed, start_game_fade_in_speed)
	_set_disable_input(false)


func _set_disable_input(value: bool):
	get_tree().get_root().set_disable_input(value)
