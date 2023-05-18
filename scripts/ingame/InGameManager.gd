class_name InGameManager
extends Node


@export var level: Node2D
@export var pause_menu: PauseMenu
@export var screen_fx_canvas_layer: ScreenFXCanvasLayer
@export var player_character: Player
@export var camera: Camera2D
@export var map: Map

@export var delivery_max_time: float = 180
@export var intro_duration: float = 1.0
@export var show_new_modifier_hint_duration: float = 1.0

@onready var hud: HUD = %HUD
@onready var scrolling_center: ScrollingCenter = %ScrollingCenter

var is_going_back_to_main_menu: bool = false

var racing_time_left: float

## During RACING phase, set this to true to pause timer
var is_time_paused: bool

func _ready():
	assert(level != null,
		"[InGameManager] level is not set on %s" % get_path())
	assert(pause_menu != null,
		"[InGameManager] pause_menu is not set on %s" % get_path())
	assert(player_character != null,
		"[InGameManager] player_character is not set on %s" % get_path())
	assert(map != null,
		"[InGameManager] map is not set on %s" % get_path())
	assert(hud != null,
		"[InGameManager] hud not found at %%HUD in same scene as %s" % get_path())

	# Hide pause menu
	pause_menu.visible = false

	# Start in intro game phase, pause logic
	GameManager.game_phase = Enums.GamePhase.INTRO
	racing_time_left = delivery_max_time

	# Wait 1 frame so children of player_character are ready
	await get_tree().physics_frame
	player_character.pause_logic()

	# wait for intro duration, pausable, physics time
	await get_tree().create_timer(intro_duration, false, true).timeout


func _physics_process(delta):
	if GameManager.game_phase == Enums.GamePhase.RACING and not is_time_paused:
		racing_time_left -= delta


func _unhandled_input(event):
	if event.is_action_pressed(&"pause"):
		if not pause_menu.visible:
			pause_menu.accept_event()
			pause_menu.open_pause_menu()
		# no need to close else, as pause_menu_controller_custom.gd is handling
		# this on their side

	if event.is_action_pressed(&"restart"):
		get_tree().reload_current_scene()

	if OS.has_feature("debug"):
		if event.is_action_pressed(&"cheat_take_damage"):
			player_character.hurt(5.0)
		elif event.is_action_pressed(&"cheat_lose_10s"):
			racing_time_left -= 10.0
		elif event.is_action_pressed(&"cheat_gain_10s"):
			racing_time_left += 10.0


func _on_pause_menu_back_to_main_pressed():
	is_going_back_to_main_menu = true

	# Disable important gameplay elements as we are resuming time before
	# going back to main, so we want to avoid any further gameplay events
	# Also remember to check is_going_back_to_main_menu before doing
	# important gameplay events that could still happen when PC is disabled,
	# such as scrolling to the end of the level
	player_character.process_mode = Node.PROCESS_MODE_DISABLED

	await GameManager.go_back_to_main_menu()


func enter_racing_phase():
	# For now, there is no intro so start racing immediately, start logic and move
	# This way, powder timer will actually start with the RACING phase
	GameManager.game_phase = Enums.GamePhase.RACING
	player_character.resume_logic()
	player_character.start_move()

	hud.show_powders_panel()
	hud.show_level_progress_bar()

	hud.powders_panel.focus_first_panel()


func enter_failure_phase():
	GameManager.enter_failure_phase(racing_time_left, player_character.cargo)


func enter_success_phase():
	GameManager.enter_success_phase(racing_time_left, player_character.cargo)


## Pause in-game elements and HUD interactions (but not Pause menu)
## Unlike opening Pause menu, this does not pause the whole scene tree
## so we can keep playing animations on the HUD (we only disable further interactions)
## and player can even open the Pause menu during this sub-phase
func pause_ingame_and_interactions():
	is_time_paused = true
	player_character.pause()
	scrolling_center.process_mode = Node.PROCESS_MODE_DISABLED
	hud.powders_panel.disable_interactions()

func resume_ingame_and_interactions():
	is_time_paused = false
	player_character.resume()
	scrolling_center.process_mode = Node.PROCESS_MODE_INHERIT
	hud.powders_panel.enable_interactions()

func play_burst_sequence_async(new_modifier: Modifier):
	if show_new_modifier_hint_duration > 0:
		pause_ingame_and_interactions()
		hud.show_new_modifier_hint(new_modifier)

		await get_tree().create_timer(show_new_modifier_hint_duration).timeout

		resume_ingame_and_interactions()
		hud.hide_new_modifier_hint()
