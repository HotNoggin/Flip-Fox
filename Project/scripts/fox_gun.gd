class_name FoxGun
extends Node3D

@export var fox: Fox
@export var multiplier: float = 0.5
@export var move_speed: float = 1.0
@export var enabled: bool = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not enabled:
		return
	rotation_degrees.y = move_toward(rotation_degrees.y, fox.suspicion * multiplier,
		delta * move_speed)
