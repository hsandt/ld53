extends Node

var _pause_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	_pause_menu = get_node("/root/test_ui2/PauseMenu")
	if not _pause_menu:
		print("not find")
	else :
		print("started")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("ui_cancel")):
		print("press pause")			
		if (_pause_menu) :
			print("open pause")				
			_pause_menu.open_pause_menu()
