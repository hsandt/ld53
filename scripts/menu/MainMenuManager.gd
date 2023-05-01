extends Node


## Main menu
@export var main_menu: MainMenu

## Speed factor for initial fade in animation
@export var initial_fade_in_speed: float = 1.0


func _ready():
	assert(main_menu != null, "[MainMenuManager] main_menu is not set on %s" % get_path())

	# Wait 1 frame so children are ready
	await get_tree().process_frame

	# Disable all buttons while fading in
	main_menu.disable_all_buttons()
	await TransitionScreen.fade_in_async(initial_fade_in_speed)
	main_menu.enable_all_buttons()


func _on_main_menu_start_game_pressed():
	# Disable all buttons before starting fading in for safety
	main_menu.disable_all_buttons()

	await GameManager.start_level()
