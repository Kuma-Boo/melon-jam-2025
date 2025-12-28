extends Node

@export var animator : AnimationPlayer
var is_transition_active : bool = true
var is_options_visible : bool
var is_selecting_level_select : bool

func _ready() -> void:
	is_selecting_level_select = GlobalManager.is_level_select
	animator.play("select-level" if is_selecting_level_select else "select-new")
	animator.advance(0.0)
	animator.play("init")

func _process(_delta: float) -> void:
	if is_transition_active:
		return
	
	if Input.is_key_pressed(KEY_SPACE) || Input.is_action_just_pressed("ui_accept"):
		if !is_options_visible:
			animator.play("show-options")
		else:
			animator.play("level-select" if is_selecting_level_select else "new-game")
		
		is_options_visible = true
		is_transition_active = true
		return
	
	if !is_options_visible:
		return
	
	if (Input.is_action_just_pressed("move_up") && is_selecting_level_select) || (Input.is_action_just_pressed("move_down") && !is_selecting_level_select):
		is_selecting_level_select = !is_selecting_level_select
		animator.play("select-level" if is_selecting_level_select else "select-new")

func finish_transition() -> void:
	is_transition_active = false

func start_new_game() -> void:
	GlobalManager.is_level_select = false
	GlobalManager.current_level_index = -1
	get_tree().change_scene_to_file(GlobalManager.get_next_level())

func start_level_select() -> void:
	GlobalManager.is_level_select = true
	get_tree().change_scene_to_file("res://scene/level select.tscn")
