extends TextureRect

@export_range(0, 1) var progression : float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	progression = clampf(progression, 0, 1)
	self.anchor_left = progression
	self.anchor_top = 0.5
	#self.set_position(Vector2(self.get_parent_area_size().x * progression, 0))
