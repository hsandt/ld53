class_name GameManagerClass
extends Node


## Main menu scene
@export var main_menu_scene: PackedScene

## In-game scene
@export var first_scene: PackedScene

## Speed factor for start game fade out animation
@export var start_game_fade_out_speed: float = 1.0

## Speed factor for start game fade in animation
@export var start_game_fade_in_speed: float = 1.0

## Speed factor for back to main menu fade out animation
@export var back_to_main_menu_fade_out_speed: float = 1.0

## Speed factor for back to main menu fade in animation
@export var back_to_main_menu_fade_in_speed: float = 1.0


func _ready():
	assert(first_scene != null,
		"[GameManager] first_scene is not set on %s" % get_path())
	assert(main_menu_scene != null,
		"[InGameManager] main_menu_scene is not set on %s" % get_path())

func start_level():
	await SceneManager.change_scene_with_fade_async(first_scene,
		start_game_fade_out_speed, start_game_fade_in_speed)

func go_back_to_main_menu():
	await SceneManager.change_scene_with_fade_async(main_menu_scene,
		back_to_main_menu_fade_out_speed, back_to_main_menu_fade_in_speed)
