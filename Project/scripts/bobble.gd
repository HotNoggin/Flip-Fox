extends Node3D

@export var bobble_speed: float = 40
@export var bobble_distance: float = 0.01

var time: float = 0.0


func _process(delta: float) -> void:
	time = wrapf(time + (delta * bobble_speed), 0, 359)
	var sine: float = sin(deg_to_rad(time))
	position.y = sine * bobble_distance
