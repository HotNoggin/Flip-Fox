extends Node3D
 
@export var distance: float = 0.005
@export var speed_1: float = 200.0
@export var speed_2: float = 38.0
@export var speed_3: float = 160

var velocity: Vector3
var time_1: float
var time_2: float
var time_3: float


func _physics_process(delta: float):
	time_1 = wrapf(time_1 + (delta * speed_1), 0, 359)
	time_2 = wrapf(time_2 + (delta * speed_2), 0, 359)
	time_3 = wrapf(time_3 + (delta * speed_3), 0, 359)
	var sin_1: float = sin(deg_to_rad(time_1))
	var sin_2: float = sin(deg_to_rad(time_2))
	var sin_3: float = sin(deg_to_rad(time_3))
	var cos_1: float = cos(deg_to_rad(time_3))
	var cos_2: float = cos(deg_to_rad(time_2))
	var offset_y: float = (sin_1 + sin_2 + cos_1) / 3
	var offset_x: float = (cos_2 + sin_1 + sin_3) / 3
	position.y = offset_y * distance
	position.x = offset_x * distance
