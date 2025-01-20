extends CanvasLayer

@export_file("*.tscn", "*.scn") var main_path: String


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		Transition.go(load(main_path))
