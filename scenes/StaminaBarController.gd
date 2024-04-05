extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value = $"..".current_stamina
	if($"..".current_stamina <= 0.0):
		value = 100;
		tint_progress = Color("#ff2c14");
	else:
		tint_progress = Color("#6cf26c");
