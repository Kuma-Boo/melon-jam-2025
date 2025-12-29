extends Node

@export var animator : AnimationPlayer
@export var select_sfx : AudioStreamPlayer
var is_transition_active : bool

func _process(_delta: float) -> void:
	if is_transition_active:
		return
	
	if Input.is_anything_pressed():
		is_transition_active = true
		select_sfx.play()
		animator.play("finish")

func finish() -> void:
	get_tree().change_scene_to_file("res://scene/title.tscn")
