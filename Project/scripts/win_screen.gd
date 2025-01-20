extends CanvasLayer

@export_file("*tscn", "*.scn") var main_path: String
@export var blurb: Label
@export var winlose: Label
@export var score: Label
@export var high: Label
@export var information: DifficultyOptions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	blurb.text = [
		"Tip: Using LUCK may lower the fox's stress.",
		"Tip: If the fox seems calm, grab some wins.",
		"Tip: Keep the fox calm by losing intentionally.",
		"Tip: Save your cheating for the biggest scores.",
		"Tip: The fox gets more stressed the more he loses."
	].pick_random()
	if information.did_win:
		winlose.text = "You weren't killed. Good job, trickster."
		blurb.text = [
			"You earned this win.", "I guess you played fair.",
			"Congrats on the win.", "Enjoy your victory."
		].pick_random()
	else:
		if information.cash_made > 0:
			winlose.text = "You were shot. Be careful next time."
		else:
			winlose.text = "You were shot. Next time keep some cash."
			score.hide()
			high.hide()
	score.text = "You made $" + str(information.cash_made) + "."
	high.text = "Your highest win is $" + str(information.high_score) + "."


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		Transition.go(load(main_path))
