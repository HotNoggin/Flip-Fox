class_name DifficultyOptions
extends Resource

@export var cash_suspicion: int = 1 ## Suspicion of cash value multiplier
@export var cash_relief: int = 1 ## Relief of cash value multiplier
@export var suspicion_limit: int = 100 ## How suspicious the fox gets before shooting
@export var flip_count: int = 50 ## How many flips it takes to win
@export var loss_streak_val: int = 18
@export var loss_streak_size: int = 4
@export var win_streak_val: int = 8
@export var win_streak_size: int = 3
@export var luck_relief: int = 3
@export var coin_streak_size: int = 3
@export var coin_streak_val: int = 8
@export var min_bet: int = 2
@export var max_bet: int = 5
@export var absolute_max_bet: int = 15

var cash_made: int = 0
var high_score: int = 0
var did_win: bool = false
