extends Node


## Main menu scene
@export var main_menu_scene: PackedScene

## In-game scene
@export var first_scene: PackedScene

## Result scene
@export var result_scene: PackedScene

## Speed factor for start game fade out animation
@export var start_game_fade_out_speed: float = 1.0

## Speed factor for start game fade in animation
@export var start_game_fade_in_speed: float = 1.0

## Speed factor for show result fade out animation
@export var show_result_fade_out_speed: float = 1.0

## Speed factor for show result fade in animation
@export var show_result_fade_in_speed: float = 1.0

## Speed factor for back to main menu fade out animation
@export var back_to_main_menu_fade_out_speed: float = 1.0

## Speed factor for back to main menu fade in animation
@export var back_to_main_menu_fade_in_speed: float = 1.0

## Current game phase
var game_phase: Enums.GamePhase = Enums.GamePhase.MAIN_MENU

## Powder stats [idle_powder_count, total_powder_stamina] on game session end to show in result
var powder_stats: Array

func _ready():
	assert(main_menu_scene != null,
		"[InGameManager] main_menu_scene is not set on %s" % get_path())
	assert(first_scene != null,
		"[GameManager] first_scene is not set on %s" % get_path())
	assert(result_scene != null,
		"[GameManager] result_scene is not set on %s" % get_path())

func start_level():
	await SceneManager.change_scene_with_fade_async(first_scene,
		start_game_fade_out_speed, start_game_fade_in_speed)

func enter_result_scene():
	await SceneManager.change_scene_with_fade_async(result_scene,
		show_result_fade_out_speed, show_result_fade_in_speed)

func go_back_to_main_menu():
	await SceneManager.change_scene_with_fade_async(main_menu_scene,
		back_to_main_menu_fade_out_speed, back_to_main_menu_fade_in_speed)


func enter_failure_phase(cargo: Cargo):
	game_phase = Enums.GamePhase.FAILURE

	# Store result before changing scene
	powder_stats = cargo.get_powder_stats()

	enter_result_scene()

func enter_success_phase(cargo: Cargo):
	game_phase = Enums.GamePhase.SUCCESS

	# Store result before changing scene
	powder_stats = cargo.get_powder_stats()

	enter_result_scene()
