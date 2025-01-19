class_name Fox
extends Node3D

@export var bet_label: Label3D
@export var label: Label3D
@export var coin: Coin
@export var suspicion: float
@export var all_calls: Array[bool]
@export var min_cash: int
@export var max_cash: int


var time: float
var my_call: bool
var bet_tween: Tween
var speech_tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_call()


func make_call() -> void:
	my_call = randi_range(0, 1) == 1
	var amount: int = randi_range(2, 5)
	var choice: String = "tails"
	if my_call:
		choice = "heads"
	bet_label.text = "I bet $" + str(amount) + " on " + choice
	bet_label.scale = Vector3.ZERO
	if bet_tween:
		bet_tween.kill()
	bet_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	bet_tween.tween_property(bet_label, "scale", Vector3.ONE, 0.5)


func check_results() -> void:
	var result: bool = coin.is_heads
	all_calls.append(result)
	if result == my_call:
		say("Ha. Called it.")
	else:
		say("...")
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
