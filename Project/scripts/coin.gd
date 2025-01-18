extends Node3D

@export var flip_animator: AnimationPlayer
@export var spin_animator: AnimationPlayer
@export var spinner: Node3D
@export var cards: Array[Card]

var is_heads: bool = false


func _ready() -> void:
	flip_animator.animation_finished.connect(land)


func flip() -> void:
	set_cards(false)
	flip_animator.play("flip")
	spin_animator.play("spin")


func head() -> void:
	is_heads = true
	flip()


func tail() -> void:
	is_heads = false
	flip()


func luck() -> void:
	is_heads = randi_range(0, 1) == 1
	flip()


func land(_anim: String) -> void:
	spin_animator.stop()
	set_cards(true)
	if is_heads:
		spinner.rotation_degrees.z = 0
	else:
		spinner.rotation_degrees.z = 180


func set_cards(enabled: bool) -> void:
	for card: Card in cards:
		card.enabled = enabled
