extends Control

@export var level_box_containers : Array[VBoxContainer]
@export var level_option : PackedScene
@export var cursor_position : Control
@export var return_to_title_option : Control
@export var animator : AnimationPlayer

@export_group("Sound Effects")
@export var move_sfx : AudioStreamPlayer
@export var select_sfx : AudioStreamPlayer

var is_transition_active : bool

var current_selection : Vector2
var selection_timer : float
const SELECTION_INTERVAL = 0.2
const SELECTION_VERTICAL_SPACING = 100
const SELECTION_HORIZONTAL_SPACING = 400

func _enter_tree() -> void:
	animator.play("init")
	animator.advance(0.0)

func _ready() -> void:
	for i in GlobalManager.level_list.size():
		var level_option_instance : Label = level_option.instantiate()
		level_option_instance.text = "Level " + str(i + 1)
		var box_index : int = i % level_box_containers.size()
		level_box_containers[box_index].add_child(level_option_instance)
	
	if GlobalManager.current_level_index != -1:
		current_selection.x = GlobalManager.current_level_index % level_box_containers.size()
		current_selection.y = GlobalManager.current_level_index / level_box_containers.size()
		update_cursor_position()

func _process(delta: float) -> void:
	if is_transition_active:
		return
	
	process_inputs()
	process_selection(delta)
	
	if Input.is_action_just_pressed("ui_accept"):
		if current_selection.y < level_box_containers[current_selection.x as int].get_child_count():
			start_level()
		else:
			return_to_title()
	elif Input.is_action_just_pressed("ui_cancel"):
		return_to_title()

func start_level() -> void:
	animator.play("start_level")
	is_transition_active = true
	select_sfx.play()

func return_to_title() -> void:
	animator.play("return")
	is_transition_active = true
	select_sfx.play()

func process_selection(delta : float) -> void:
	if last_input_direction.is_zero_approx():
		selection_timer = 0
		return
	
	if !is_zero_approx(selection_timer):
		selection_timer = move_toward(selection_timer, 0, delta)
		return
	
	var previous_selection : Vector2 = current_selection
	current_selection += last_input_direction
	current_selection.x = clamp(current_selection.x, 0, level_box_containers.size() - 1)
	current_selection.y = clamp(current_selection.y, 0, level_box_containers[current_selection.x as int].get_child_count())
	
	if current_selection.y >= level_box_containers[current_selection.x as int].get_child_count():
		current_selection.x = 1
	
	if current_selection.is_equal_approx(previous_selection):
		return
	
	update_cursor_position()
	move_sfx.play()
	selection_timer = SELECTION_INTERVAL

func update_cursor_position() -> void:
	if current_selection.y < level_box_containers[current_selection.x as int].get_child_count():
		cursor_position.global_position = level_box_containers[0].global_position + current_selection * Vector2(SELECTION_HORIZONTAL_SPACING, SELECTION_VERTICAL_SPACING)
	else:
		cursor_position.global_position = return_to_title_option.global_position

var prioritize_horizontal_inputs : bool
var last_input_direction : Vector2
func process_inputs() -> void:
	if Input.is_action_just_pressed("move_left") || Input.is_action_just_pressed("move_right"):
		prioritize_horizontal_inputs = true
	elif Input.is_action_just_pressed("move_up") || Input.is_action_just_pressed("move_down"):
		prioritize_horizontal_inputs = false
	
	var horizontal_input : int = sign(Input.get_axis("move_left", "move_right"));
	var vertical_input : int = sign(Input.get_axis("move_up", "move_down"));
	if abs(horizontal_input) > abs(vertical_input) || (horizontal_input != 0 && prioritize_horizontal_inputs):
		last_input_direction = Vector2.RIGHT * horizontal_input
	elif abs(horizontal_input) < abs(vertical_input) || (vertical_input != 0 && !prioritize_horizontal_inputs):
		last_input_direction = Vector2.DOWN * vertical_input
	else:
		last_input_direction = Vector2.ZERO

func load_level() -> void:
	GlobalManager.is_level_select = true
	GlobalManager.current_level_index = round(current_selection.y * level_box_containers.size() + current_selection.x) - 1
	get_tree().change_scene_to_file(GlobalManager.get_next_level())

func load_title() -> void:
	get_tree().change_scene_to_file("res://scene/title.tscn")
