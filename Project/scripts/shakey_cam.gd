extends Node3D
 
@onready var noise = FastNoiseLite.new()
 
@export var decay: float = 0.0
@export var amplitude: float = 0.1
@export var pos_min: Vector3 = Vector3.ONE * -0.1
@export var pos_max: Vector3 = Vector3.ONE * 0.1
 
var trauma: float = 1.0
var NOISE_SPEED: float = 0.2
var _noise_y: float = 0


func _ready():
	randomize()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
 

func _physics_process(_delta):
	if not is_zero_approx(trauma):
		_noise_y += NOISE_SPEED
		_shake()


func _shake():
	var amount = trauma
	position.x = amplitude * amount * noise.get_noise_2d(noise.seed, _noise_y)
	position.y = amplitude * amount * noise.get_noise_2d(noise.seed * 2, _noise_y)
	position.z = amplitude * amount * noise.get_noise_2d(noise.seed * 3, _noise_y)
	position = position.clamp(pos_min, pos_max)
