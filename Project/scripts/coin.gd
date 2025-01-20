class_name Coin
extends Node3D

signal landed

@export var flip_animator: AnimationPlayer
@export var spin_animator: AnimationPlayer
@export var flip_sound: AudioStreamPlayer
@export var drop_sound: AudioStreamPlayer
@export var spinner: Node3D
@export var cards: Array[Card]

var is_heads: bool = false
var is_lucky: bool = false


func _ready() -> void:
	flip_animator.animation_finished.connect(land)


func flip() -> void:
	set_cards(false)
	flip_animator.play("flip")
	spin_animator.play("spin")
	flip_sound.play()


func head() -> void:
	is_lucky = false
	is_heads = true
	flip()


func tail() -> void:
	is_lucky = false
	is_heads = false
	flip()


func luck() -> void:
	is_lucky = true
	is_heads = randi_range(0, 1) == 1
	flip()


func land(_anim: String) -> void:
	drop_sound.play()
	spin_animator.stop()
	set_cards(true)
	if is_heads:
		spinner.rotation_degrees.z = 0
	else:
		spinner.rotation_degrees.z = 180
	landed.emit()


func set_cards(enabled: bool) -> void:
	for card: Card in cards:
		card.enabled = enabled


func hide_cards() -> void:
	set_cards(false)
	for card: Card in cards:
		card.hide()
