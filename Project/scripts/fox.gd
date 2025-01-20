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
	var is_heads: bool = coin.is_heads
	var upside: String = "tails"
	var fox_won: bool = is_heads == my_call
	if is_heads:
		upside = "heads"
	all_results.append(is_heads)
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
	#endregion
	
	#region: low suspicion
	if is_heads == my_call:
		remarks = [
			"Called it.", "The coin's on my side.", "Give me your money.",
			"I'm just lucky.", "I knew it.", "I could just tell.", "I'm a coin whisperer.",
			"Just like I said.", "Never doubted it.", "You owe me.", "Pay up.",
			"That's " + str(my_bet) + ", buddy."
		]
	else:
		remarks = [
			"...", "That should've been " + choice + ".", "That's strange.",
			"That isn't right...", "Why wasn't it " + choice + "?", "Just my luck.",
			"Bad guess.", "I guess I owe you.", "Fine, take my $" + str(my_bet) + "."
		]
	#endregion
	
	#region: coin streaks
	var reversed_results: Array[bool] = all_results.duplicate()
	reversed_results.reverse()
	
	if all_results.size() >= ai.coin_streak_size:
		var coin_streak: Array[bool] = all_results.slice(-ai.coin_streak_size)
		var end_coin: bool = coin_streak.front()
		# Long streak of one side -> add suspicion
		if not (TAILS in coin_streak) or not (HEADS in coin_streak):
			suspicion += ai.coin_streak_val
			var streak_length: int = 0
			for coin_face: bool in reversed_results:
				if coin_face != end_coin:
					break
				streak_length+= 1
			
			remarks = [
				"Wow!\nI've won " + str(streak_length) + " in a row!",
				"Lucky!\nMy streak is at " + str(streak_length) + "!",
				"\n Already at " + str(streak_length) + " this streak!",
				"Yes!\n" + str(streak_length)  +" wins in a row!"
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
			remarks = [
				"Cheater!\nI've lost " + str(streak_length) + " in a row!",
				"This is rigged!\nI've lost " + str(streak_length) + " in a row!",
				"You thief!\nThat's a " + str(streak_length) + "-loss streak!",
				str(streak_length) + " losses in a row!?\nTrickster!"
			]
	#endregion
	
	#region: wrapup, win + lose
	suspicion = clampi(suspicion, 0, 100)
	
	print("Suspicion: " + str(suspicion))
	print("Flips made: " + str(all_results.size()))
	print("-")
	
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
