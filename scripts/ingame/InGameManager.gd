class_name InGameManager
extends Node


@export var pause_menu: PauseMenu
@export var player_character: Player
@export var intro_duration: float = 1.0

@onready var hud: HUD = %HUD

var game_phase: Enums.GamePhase
var is_going_back_to_main_menu: bool = false

func _ready():

	assert(pause_menu != null,
		"[InGameManager] pause_menu is not set on %s" % get_path())
	assert(player_character != null,
		"[InGameManager] player_character is not set on %s" % get_path())
	assert(hud != null,
		"[InGameManager] hud not found at %%HUD in same scene as %s" % get_path())

	# Hide pause menu
	pause_menu.visible = false

	# Start in intro game phase
	game_phase = Enums.GamePhase.INTRO

	# wait for intro duration, pausable, physics time
	await get_tree().create_timer(intro_duration, false, true).timeout

	# For now, there is no intro so start racing immediately
	game_phase = Enums.GamePhase.RACING
	player_character.start_move()


func _unhandled_input(event):
	if event.is_action_pressed(&"pause"):
		if not pause_menu.visible:
			pause_menu.accept_event()
			pause_menu.open_pause_menu()
		# no need to close else, as pause_menu_controller_custom.gd is handling
		# this on their side

	if event.is_action_pressed(&"restart"):
		get_tree().reload_current_scene()


func enter_failure_phase():
	game_phase = Enums.GamePhase.FAILURE


func enter_success_phase():
	game_phase = Enums.GamePhase.SUCCESS


func _on_pause_menu_back_to_main_pressed():
	is_going_back_to_main_menu = true

	# Disable important gameplay elements as we are resuming time before
	# going back to main, so we want to avoid any further gameplay events
	# Also remember to check is_going_back_to_main_menu before doing
	# important gameplay events that could still happen when PC is disabled,
	# such as scrolling to the end of the level
	player_character.process_mode = Node.PROCESS_MODE_DISABLED

	await GameManager.go_back_to_main_menu()
