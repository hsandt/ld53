extends Control


@export var time_label: Label

var in_game_manager: InGameManager


func _ready():
	assert(time_label != null, "[Powder] time_label is not set on %s" % get_path())

	in_game_manager = get_tree().get_first_node_in_group(&"in_game_manager")

func _process(_delta):
	time_label.text = "%.1fs" % in_game_manager.racing_time
