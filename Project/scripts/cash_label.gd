extends Node3D

@export var bounce_scale: float = 1.2
@export var fox: Fox

var tween: Tween
var last_cash: int

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if last_cash != fox.player_cash:
		scale = Vector3.ONE * bounce_scale
		if tween:
			tween.kill()
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.tween_property(self, "scale", Vector3.ONE, 1.0)
	last_cash = fox.player_cash
