extends Node


## Main menu
@export var main_menu: MainMenu

## Speed factor for initial fade in animation
@export var initial_fade_in_speed: float = 1.0


func _ready():
	assert(main_menu != null, "[MainMenuManager] main_menu is not set on %s" % get_path())

	GameManager.game_phase = Enums.GamePhase.MAIN_MENU

	# Wait 1 frame so children are ready
	await get_tree().process_frame

	# Disable all buttons while fading in
	main_menu.disable_all_buttons()

	if TransitionScreen.animation_player.current_animation.is_empty():
		# No transition, we must be entering main menu for the first time
		await TransitionScreen.fade_in_async(initial_fade_in_speed)
	else:
		# Transition is already playing fade, so we must be coming back from
		# another scene, and playing fade-in, so just wait for it to finish
		# before enabling all buttons
		await TransitionScreen.animation_player.animation_finished

	main_menu.enable_all_buttons()

func _on_main_menu_start_game_pressed():
	# Disable all buttons before starting fading in for safety
	main_menu.disable_all_buttons()

	await GameManager.start_level()
