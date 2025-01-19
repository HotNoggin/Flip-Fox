extends Node3D

@export var fox: Fox
@export var multiplier: float = 0.5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	rotation_degrees.y = fox.suspicion * multiplier
