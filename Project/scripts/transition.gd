extends CanvasLayer

@export var animator: AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animator.play_backwards("fade_in")


func go(scene: PackedScene) -> void:
	get_tree().paused = true
	animator.play("fade_in")
	await  animator.animation_finished
	get_tree().change_scene_to_packed(scene)
	get_tree().paused = false
	animator.play_backwards("fade_in")
