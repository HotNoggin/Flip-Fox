class_name Fox
extends Node3D

@export var bet_label: Label3D
@export var label: Label3D
@export var cash_label: Label3D
@export var coin: Coin
@export var suspicion: float
@export var all_calls: Array[bool]
@export var min_cash: int
@export var max_cash: int
@export var player_cash: int = 10


var time: float
var my_call: bool
var my_bet: int
var choice: String
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


func check_results() -> void:
	var result: bool = coin.is_heads
	all_calls.append(result)
	
	var remarks: Array[String]
	
	if result == my_call:
		remarks = [ "Called it.", "The coin's on my side.", "Give me your money.",
			"I'm just lucky.", "I knew it.", "I could just tell.", "I'm a coin whisperer.",
			"Just like I said.", "Never doubted it.", "You owe me.", "Pay up.",
			"That's " + str(my_bet) + ", buddy."
		]
		player_cash -= my_bet
	else:
		remarks = ["...", "That should've been " + choice + ".", "That's strange.",
			"That isn't right...", "Why wasn't it " + choice + "?", "Just my luck.",
			"Bad guess.", "I guess I owe you.", "Fine, take my $" + str(my_bet) + "."
			]
		player_cash += my_bet
		suspicion += my_bet
	
	cash_label.text = "You have $" + str(player_cash) + "."
	say_random(remarks)
	make_call()


func say_random(texts: Array[String]) -> void:
	say(texts.pick_random())


func say(text: String) -> void:
	label.text = text
	label.scale = Vector3.ZERO
	if speech_tween:
		speech_tween.kill()
	speech_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	speech_tween.tween_property(label, "scale", Vector3.ONE, 0.5)
