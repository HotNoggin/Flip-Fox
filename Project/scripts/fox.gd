class_name Fox
extends Node3D

const HEADS: bool = true
const TAILS: bool = false

@export var ai: DifficultyOptions
@export var bet_label: Label3D
@export var label: Label3D
@export var cash_label: Label3D
@export var coin: Coin
@export var cash_sound: AudioStreamPlayer
@export var pose_animator: AnimationPlayer
@export var arm: FoxGun
@export var win_scene: PackedScene
@export var suspicion: int
@export var player_cash: int = 10


var time: float
var my_call: bool
var my_bet: int
var choice: String
var all_results: Array[bool]
var all_wins: Array[bool]
var bet_tween: Tween
var speech_tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cash_label.text = "You have $" + str(player_cash) + "."
	make_call()


func make_call() -> void:
	my_call = randi_range(0, 1) == 1
	my_bet = randi_range(2, 5)
	choice = "tails"
	if my_call:
		choice = "heads"
	bet_label.text = "I bet $" + str(my_bet) + " on " + choice
	bet_label.scale = Vector3.ZERO
	if bet_tween:
		bet_tween.kill()
	bet_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	bet_tween.tween_property(bet_label, "scale", Vector3.ONE, 0.5)
	print("Fox bets $" + str(my_bet) + " on " + choice)


func check_results() -> void:
	#region: basic rules, coin check
	var result: bool = coin.is_heads
	var upside: String = "tails"
	var fox_won: bool = result == my_call
	if result:
		upside = "heads"
	all_results.append(result)
	all_wins.append(fox_won)
	
	print("The coin lands on " + upside)
	
	var remarks: Array[String]
	
	if fox_won:
		player_cash -= my_bet
		suspicion -= my_bet * ai.cash_suspicion
	else:
		player_cash += my_bet
		suspicion += my_bet * ai.cash_relief
		cash_sound.play()
	if coin.is_lucky:
		suspicion -= ai.luck_relief
		print("- Lucky toss")
	
	print("The player has $" + str(player_cash))
	#endregion
	
	#region: low suspicion
	if fox_won:
		remarks = [
			"Called it.", "The coin's on my side.", "Give me your money.",
			"I'm just lucky.", "I knew it.", "I could just tell.", "I'm a coin whisperer.",
			"Just like I said.", "Never doubted it.", "You owe me.", "Pay up.",
			"That's $" + str(my_bet) + ", buddy."
		]
	else:
		remarks = [
			"...", "That should've been " + choice + ".", "That's strange.",
			"That isn't right...", "Why wasn't it " + choice + "?", "Just my luck.",
			"Bad guess.", "I guess I owe you.", "Fine, take my $" + str(my_bet) + "."
		]
	#endregion
	
	#region: mid suspicion
	if suspicion >= 33:
		if fox_won:
			remarks = [
				"A win.\nBut something feels off.", "That win didn't feel lucky.",
				"Yes.\nAre you playing games?", "Pay up...\ntrickster...",
				"That's $" + str(my_bet) +".\nBut was it fair?",
				"This $" + str(my_bet) + " feels dirty.",
				"$" + str(my_bet) + " from a trickster.", "This win feels strange.",
				"Called it.\nBut I don't feel so lucky.", "I didn't expect " + upside + ".",
				"Oh, it really is " + upside + "?"
		]
		else:
			remarks = [
				"You stole that win.", "This isn't luck.\nIt's trickery.",
				"Are you some kind of thief?", "You're controling this.\nAren't you?",
				"You're making me suspicious.", "Are you running a con?",
				"That's not possible.\nYou're lying.", "None of this is right.",
				"I smell a cheater.", "Someone's looking to get shot.",
				"You made it land on " + upside + ".\nDidn't you?",
				"That " + upside + " was forced.", "You're stealing from me.",
				"That $" + str(my_bet) + " is stolen money.", "Lies.", "Cheater."
			]
	#endregion
	
	#region: high suspicion
	if suspicion >= 67:
		if fox_won:
			remarks = [
				"You think THAT will calm me!?", "This is all a CON!",
				"You owe me more than that!", "$" + str(my_bet) + " won't hide LIES!",
				"I smell a cheater!\nI SHOOT cheaters!"
		]
		else:
			remarks = [
				"You're CHEATING!", "That's NOT possible!", "You're a LIAR!",
				"You're just a THIEF!", "I'm gonna SHOOT you!",
				"When I run out of money,\nI'll run out of PATIENCE!",
				"That $" + str(my_bet) + " is STOLEN!", "Someone's looking to DIE!",
				"You MADE it land on " + upside + "!",
				"That SHOULD have been " + choice + "!",
				"You STOLE that $" + str(my_bet) + " from me!",
				"You STOLE that " + choice + " from me!"
			]
	#endregion
	
	#region: coin streaks
	var reversed_results: Array[bool] = all_results.duplicate()
	reversed_results.reverse()
	
	if all_results.size() >= ai.coin_streak_size:
		var coin_streak: Array[bool] = all_results.slice(-ai.coin_streak_size)
		# Long streak of one side -> add suspicion
		if not (TAILS in coin_streak) or not (HEADS in coin_streak):
			suspicion += ai.coin_streak_val
			var streak_length: int = 0
			for coin_face: bool in reversed_results:
				if coin_face != result:
					break
				streak_length+= 1
			
			print("+ Coin streak: " + str(streak_length))
			remarks = [
				"Strange.\nThat's " + str(streak_length) + " " + upside + " in a row.",
				"What is this?\n" + str(streak_length) + " " + upside + " in a row!?",
				"Something's off!\n Already at "
					+ str(streak_length) + " " + upside + " now!",
				"What!?\n" + str(streak_length) + " " + upside + " in a row now!?"
			]
	#endregion
	
	#region: streaks
	var reversed_wins: Array[bool] = all_wins.duplicate()
	reversed_wins.reverse()
	
	if all_wins.size() >= ai.win_streak_size:
		var win_streak: Array[bool] = all_wins.slice(-ai.win_streak_size)
		# No losses -> lower guard
		if not (false in win_streak):
			suspicion -= ai.win_streak_val
			var streak_length: int = 0
			for did_win: bool in reversed_wins:
				if not did_win:
					break
				streak_length+= 1
			
			print("- Win streak: " + str(streak_length))
			remarks = [
				"Wow!\nI've won " + str(streak_length) + " in a row!",
				"Lucky!\nMy streak is at " + str(streak_length) + "!",
				"\n Already at " + str(streak_length) + " this streak!",
				"Yes!\n" + str(streak_length)  +" wins in a row!"
			]
	
	if all_wins.size() >= ai.loss_streak_size:
		var win_streak: Array[bool] = all_wins.slice(-ai.loss_streak_size)
		# No wins -> get suspicious
		if not (true in win_streak):
			suspicion += ai.loss_streak_val
			var streak_length: int = 0
			for did_win: bool in reversed_wins:
				if did_win:
					break
				streak_length+= 1
				
			print("+ Lose streak: " + str(streak_length))
			remarks = [
				"Cheater!\nI've lost " + str(streak_length) + " in a row!",
				"This is rigged!\nI've lost " + str(streak_length) + " in a row!",
				"You thief!\nThat's a " + str(streak_length) + "-loss streak!",
				str(streak_length) + " losses in a row!?\nTrickster!"
			]
	#endregion
	
	#region: dangerous suspicion
	if suspicion >= 90:
		remarks = [
			"FAKE!", "CON!", "LIAR!", "CHEATER!", "LIES!", "CHEAT!",
			"I'M GONNA MURDER YOU!", "I WILL SHOOT!", "STOP THIS!",
			"THIEF!", "YOU'RE GONNA DIE!", "YOU'RE GONNA PAY!"
		]
	#endregion
	
	#region: wrapup, win + lose
	suspicion = clampi(suspicion, 0, 100)
	
	print("= Suspicion: " + str(suspicion))
	print("  Flips made: " + str(all_results.size()))
	print("")
	
	cash_label.text = "You have $" + str(player_cash) + "."
	
	ai.cash_made = player_cash
	if ai.cash_made > ai.high_score:
		ai.high_score = ai.cash_made
	
	# Suspicion loss
	if suspicion >= ai.suspicion_limit:
		coin.hide_cards()
		ai.did_win = false
		arm.enabled = false
		pose_animator.play("shoot")
		pose_animator.animation_finished.connect(func(_anim: String) -> void:
			Transition.go(win_scene)
		)
		say_random([
			"YOU'RE CHEATING!", "STOP CHEATING!", "TRICKSTER!", "LIAR!", "THIEF!",
			"CHEATER!", "YOU'RE LYING!", "THIS IS RIGGED!"
		])
		return
	
	# Debt loss
	if player_cash <= 0:
		coin.hide_cards()
		ai.did_win = false
		arm.enabled = false
		pose_animator.play("shoot")
		pose_animator.animation_finished.connect(func(_anim: String) -> void:
			Transition.go(win_scene)
		)
		say_random([
			"Your wallet's empty.", "You're in debt.", "You've got nothing left.",
			"Time to pay up.", "Thanks for the cash."
		])
		return
	
	# Win
	if all_results.size() >= ai.flip_count:
		coin.hide_cards()
		ai.did_win = true
		say_random([
			"Alright, good fun.", "Good game, little fox.", "Fair game, good game.",
			"I think I'm done now.", "Let's quit now, bud.", "I'm done, little fox."
		])
		await get_tree().create_timer(2.0).timeout
		Transition.go(win_scene)
		return
	
	say_random(remarks)
	make_call()
	#endregion


func say_random(texts: Array[String]) -> void:
	say(texts.pick_random())


func say(text: String) -> void:
	label.text = text
	label.scale = Vector3.ZERO
	if speech_tween:
		speech_tween.kill()
	speech_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	speech_tween.tween_property(label, "scale", Vector3.ONE, 0.5)


func get_average(array: Array[int]) -> int:
	var avg: int = 0
	for item: int in array:
		avg += item
	@warning_ignore("integer_division")
	return avg / array.size()
