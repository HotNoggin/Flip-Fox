extends CanvasLayer

@export_file("*tscn", "*.scn") var main_path: String
@export var blurb: Label
@export var winlose: Label
@export var score: Label
@export var high: Label
@export var information: DifficultyOptions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if information.did_win:
		winlose.text = "You weren't killed. Good job, trickster."
		blurb.text = [
			"You earned this win.", "I guess you played fair.",
			"Congrats on the win.", "Enjoy your victory."
		].pick_random()
	else:
		if information.cash_made > 0:
			winlose.text = "You were shot. Be careful next time."
			blurb.text = [
				"I knew you were cheating.", "I don't like a cheater.",
				"Taste gunpowder, trickster."
			].pick_random()
		else:
			winlose.text = "You were shot. Next time keep some cash."
			blurb.text = [
				"You have nothing left to give.", "Your wallet is empty.",
				"You ran out of cash.", "You can't bet without cash.",
				"You're all out of money."
			].pick_random()
			score.hide()
			high.hide()
	score.text = "You made $" + str(information.cash_made) + "."
	high.text = "Your highest win is $" + str(information.high_score) + "."


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		Transition.go(load(main_path))
