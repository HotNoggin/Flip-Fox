@tool
class_name Card
extends Area3D

signal click

@export var enabled: bool = true
@export var texture: Texture2D:
	set(val):
		if sprite:
			sprite.texture = val
		texture = val
@export_group("Connections")
@export var sprite: SpriteBase3D
@export var light: Light3D
@export var spinner: Node3D
@export_group("Bobble", "bobble_")
@export var bobble_speed: float = 40
@export var bobble_distance: float = 0.01
@export_group("Hover", "hover_")
@export var hover_scale: Vector3 = Vector3.ONE * 1.2
@export var hover_speed: float = 2.0
@export var hover_rotation_speed: float = 600.0

var is_hovered: bool = false
var time: float = 0.0


func _ready() -> void:
	time = randf_range(0, 360)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	time = wrapf(time + (delta * bobble_speed), 0, 359)
	var sine: float = sin(deg_to_rad(time))
	spinner.position.y = sine * bobble_distance
	
	if Input.is_action_just_pressed("click"):
		if is_hovered and enabled:
			click.emit()
	if is_hovered:
		light.visible = true
		scale = scale.move_toward(hover_scale, hover_speed * delta)
		spinner.rotation_degrees.y = move_toward(
			spinner.rotation_degrees.y, -180, hover_rotation_speed * delta)
	else:
		light.visible = false
		scale = scale.move_toward(Vector3.ONE, hover_speed * delta)
		spinner.rotation_degrees.y = move_toward(
			spinner.rotation_degrees.y, 0, hover_rotation_speed * delta)


func _mouse_enter() -> void:
	is_hovered = true


func _mouse_exit() -> void:
	is_hovered = false
