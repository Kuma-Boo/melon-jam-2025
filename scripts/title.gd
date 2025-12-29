extends Node

@export var animator : AnimationPlayer

@export_group("Sound Effects")
@export var move_sfx : AudioStreamPlayer
@export var select_sfx : AudioStreamPlayer

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
	
	if !is_options_visible && Input.is_anything_pressed():
		animator.play("show-options")
		start_transition()
		return
	
	if Input.is_action_just_pressed("space") || Input.is_action_just_pressed("ui_accept"):
		animator.play("level-select" if is_selecting_level_select else "new-game")
		start_transition()
		return
	
	if !is_options_visible:
		return
	
	if (Input.is_action_just_pressed("move_up") && is_selecting_level_select) || (Input.is_action_just_pressed("move_down") && !is_selecting_level_select):
		is_selecting_level_select = !is_selecting_level_select
		move_sfx.play()
		animator.play("select-level" if is_selecting_level_select else "select-new")

func start_transition() -> void:
	is_options_visible = true
	is_transition_active = true
	select_sfx.play()

func finish_transition() -> void:
	is_transition_active = false

func start_new_game() -> void:
	GlobalManager.is_level_select = false
	GlobalManager.current_level_index = -1
	get_tree().change_scene_to_file(GlobalManager.get_next_level())

func start_level_select() -> void:
	GlobalManager.is_level_select = true
	get_tree().change_scene_to_file("res://scene/level select.tscn")
