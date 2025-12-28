extends Node

@export var animator : AnimationPlayer
var is_transition_active : bool

func _process(_delta: float) -> void:
	if is_transition_active:
		return
	
	if Input.is_key_pressed(KEY_SPACE):
		is_transition_active = true
		animator.play("start-game")

func start_new_game() -> void:
	GlobalManager.is_level_select = false
	GlobalManager.current_level_index = 0
	get_tree().change_scene_to_file(GlobalManager.get_next_level())
