extends Node

@export var animator : AnimationPlayer
var is_transition_active : bool

func _process(_delta: float) -> void:
	if is_transition_active:
		return
	
	if Input.is_key_pressed(KEY_SPACE):
		is_transition_active = true
		animator.play("finish")

func finish() -> void:
	get_tree().change_scene_to_file("res://scene/title.tscn")
