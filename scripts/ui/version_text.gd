extends Label


func _ready():
	text = ProjectSettings.get_setting("application/config/version", "1.0.0")
