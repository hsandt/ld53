class_name InGameManager
extends Node


@export var level: Node2D
@export var pause_menu: PauseMenu
@export var screen_fx_canvas_layer: ScreenFXCanvasLayer
@export var player_character: Player
@export var map: Map

@export var delivery_max_time: float = 180.0
## Min time tolerated to end delivery
## Normally 0, we tolerate negative numbers!
@export var delivery_timer_limit: float = 0.0
@export var intro_duration: float = 1.0
@export var burst_sequence_pause_duration: float = 1.0
@export var burst_sequence_show_new_modifier_hint_duration: float = 1.0

@onready var hud: HUD = %HUD
@onready var scrolling_center: ScrollingCenter = %ScrollingCenter

var is_going_back_to_main_menu: bool

var racing_time_left: float

## During RACING phase, set this to true to pause timer
var is_time_paused: bool

var _should_restart: bool

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

	is_going_back_to_main_menu = false

	# Hide pause menu
	pause_menu.visible = false

	# Start in intro game phase, pause logic
	GameManager.game_phase = Enums.GamePhase.INTRO
	racing_time_left = delivery_max_time

	is_time_paused = false
	_should_restart = false

	# Wait 1 frame so children of player_character are ready
	await get_tree().physics_frame
	player_character.pause_logic()

	# wait for intro duration, pausable, physics time
	await get_tree().create_timer(intro_duration, false, true).timeout


func _physics_process(delta):
	# we use physics process for timer just because it's more accurate
	# and will match player motion
	if GameManager.game_phase == Enums.GamePhase.RACING and not is_time_paused:
		racing_time_left -= delta
		if racing_time_left <= delivery_timer_limit:
			# avoid time falling a bit below e.g. if limit is 0:00
			# don't show -0:01 nor use it to compute final score
			racing_time_left = delivery_timer_limit
			player_character.try_start_failure_sequence()


func _process(_delta):
	if _should_restart:
		restart_level_immediate()


func _unhandled_input(event):
	if event.is_action_pressed(&"pause"):
		if not pause_menu.visible:
			pause_menu.accept_event()
			pause_menu.open_pause_menu()
		# no need to close else, as pause_menu_controller_custom.gd is handling
		# this on their side

	if event.is_action_pressed(&"restart"):
		restart_level()

	if OS.has_feature("debug"):
		if event.is_action_pressed(&"cheat_take_damage"):
			player_character.hurt(5.0)
		# true is to allow echo to repeat warp quickly
		elif event.is_action_pressed(&"cheat_lose_10s", true):
			racing_time_left -= 10.0
		elif event.is_action_pressed(&"cheat_gain_10s", true):
			racing_time_left += 10.0
		# first true is to allow echo to repeat warp quickly
		# exact modifier check to avoid conflict with cheat_warp_forward2
		# which should require Shift
		elif event.is_action_pressed(&"cheat_warp_forward", true, true):
			player_character.position += 1000.0 * Vector2.RIGHT
			if player_character.global_position > map.goal_area.global_position:
				player_character.global_position = map.goal_area.global_position
		elif event.is_action_pressed(&"cheat_warp_forward2", true, true):
			player_character.position += 10000.0 * Vector2.RIGHT
			if player_character.global_position > map.goal_area.global_position:
				player_character.global_position = map.goal_area.global_position
		elif event.is_action_pressed(&"cheat_toggle_god_mode"):
			player_character.toggle_god_mode_enabled()


func _on_pause_menu_back_to_main_pressed():
	is_going_back_to_main_menu = true

	# Disable important gameplay elements as we are resuming time before
	# going back to main, so we want to avoid any further gameplay events
	# Also remember to check is_going_back_to_main_menu before doing
	# important gameplay events that could still happen when PC is disabled,
	# such as scrolling to the end of the level
	player_character.process_mode = Node.PROCESS_MODE_DISABLED

	await GameManager.go_back_to_main_menu()


func _on_pause_menu_restart_pressed():
	restart_level()


func restart_level():
	# Following the example in
	# https://docs.godotengine.org/en/latest/tutorials/scripting/singletons_autoload.html
	# we defer changing scene to avoid deleting nodes required by code currently running
	# It turns out this works well even with direct call
	call_deferred("restart_level_immediate")


func restart_level_immediate():
	get_tree().reload_current_scene()


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
	# don't await this sub-sequence, let it run in the wild in parallel to
	# the pause sequence since we don't care about when it ends (during or after
	# the pause)
	show_new_modifier_hint_async(new_modifier)

	if burst_sequence_pause_duration > 0:
		pause_ingame_and_interactions()
		# process_always: false so sequence pauses with Pause Menu
		await get_tree().create_timer(burst_sequence_pause_duration, false).timeout
		resume_ingame_and_interactions()

func show_new_modifier_hint_async(new_modifier: Modifier):
	hud.show_new_modifier_hint(new_modifier)
	# process_always: false so sub-sequence pauses with Pause Menu
	await get_tree().create_timer(burst_sequence_show_new_modifier_hint_duration, false).timeout
	hud.hide_new_modifier_hint()
