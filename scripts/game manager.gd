@tool
extends Control
class_name GameManager

static var instance : GameManager

signal killing_characters
const TILE_SIZE = 100
const TILE_OFFSET = Vector2.ONE * TILE_SIZE * 0.5
const SPACE_SHARE_AMOUNT = TILE_SIZE * 0.3

@export_tool_button("Generate Grid") var generate = setup_grid
@export var grid_size : Vector2i
@export var level_start_time : int

func _enter_tree() -> void:
	setup_grid()
	
	if Engine.is_editor_hint():
		return
	
	instance = self
	GlobalManager.update_current_level_index()
	
	time_left = level_start_time
	update_time_left_interface()
	
	animator.play("fade-in")
	animator.advance(0.0)
	
	update_level_text()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if is_transition_active:
		return
	
	if animator.is_playing():
		return
	
	if is_pause_menu_active:
		process_pause_menu(delta)
	else:
		check_pause_menu()

@export_group("Sound Effects")
@export var move_sfx : AudioStreamPlayer
@export var select_sfx : AudioStreamPlayer
var is_pause_menu_active : bool
var pause_menu_selection : int
var pause_selection_timer : float
const SELECTION_INTERVAL : float = 0.2
func check_pause_menu() -> void:
	if Input.is_action_just_pressed("space"):
		get_tree().paused = true
		pause_menu_selection = 0
		is_pause_menu_active = true
		select_sfx.play()
		animator.play("pause-0")
		animator.advance(0.0)
		animator.play("pause-show")

func process_pause_menu(delta : float) -> void:
	if Input.is_action_just_pressed("space"):
		is_pause_menu_active = false
		get_tree().paused = false
		select_sfx.play()
		if pause_menu_selection == 0:
			animator.play("pause-hide")
		elif pause_menu_selection == 1:
			reload_transition()
		elif pause_menu_selection == 2:
			quit_transition()
		return
	
	var input : int = sign(Input.get_axis("move_left", "move_right"))
	if input == 0:
		pause_selection_timer = 0
		return
	
	if !is_zero_approx(pause_selection_timer):
		pause_selection_timer = move_toward(pause_selection_timer, 0, delta)
		return
	
	var previous_selection = pause_menu_selection
	pause_menu_selection += input
	pause_menu_selection = clamp(pause_menu_selection, 0, 2)
	
	if previous_selection == pause_menu_selection:
		return
	
	pause_selection_timer = SELECTION_INTERVAL
	move_sfx.play()
	animator.play("pause-" + str(pause_menu_selection))
	animator.advance(0.0)


func update_level_text() -> void:
	var level_text : String = get_tree().current_scene.get_scene_file_path()
	var level_text_array = level_text.split("/")
	level_text = level_text_array[level_text_array.size() - 1].replace(".tscn", "")
	level_text = level_text.replace("level", "LEVEL ")
	level_label.text = level_text

@export_group("Components")
@export var grid_rect : TextureRect
func setup_grid() -> void:
	if grid_rect != null:
		grid_rect.size = TILE_SIZE * (grid_size as Vector2)

func clamp_position(pos : Vector2) -> Vector2:
	pos.x = clamp(pos.x, 0, grid_size.x - 1)
	pos.y = clamp(pos.y, 0, grid_size.y - 1)
	pos = pos.round()
	return pos

@export var animator : AnimationPlayer
static var is_transition_active : bool
func reload_transition() -> void:
	target_scene = ""
	is_transition_active = true
	animator.play("fade-out")

func quit_transition() -> void:
	if GlobalManager.is_level_select:
		target_scene = "res://scene/level select.tscn"
	else:
		target_scene = "res://scene/title.tscn"
	is_transition_active = true
	animator.play("fade-out")

func finish_transition() -> void:
	is_transition_active = false

var target_scene : StringName
func load_scene() -> void:
	if target_scene.is_empty():
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file(target_scene)

func spirit_transition() -> void:
	is_transition_active = true
	animator.play("spirit");

@export var time_interface_head : Sprite2D
@export var remaining_moves_label : Label
@export var bonus_moves_label : Label
@export var level_label : Label
var time_left : int
var bonus_time : int
const max_head_position = 380;

func update_time() -> bool:
	if bonus_time > 0:
		bonus_time -= 1
	else:
		time_left -= 1
	time_left = max(time_left, 0)
	
	update_time_left_interface()
	return time_left == 0

func force_timeout() -> void:
	time_left = 0
	bonus_time = 0
	Player.instance.advance_time()

func add_bonus_time() -> void:
	bonus_time = 6

func update_time_left_interface() -> void:
	var target_head_position = lerp(max_head_position, 0, time_left / (level_start_time as float));
	time_interface_head.position = Vector2(target_head_position, time_interface_head.position.y)
	remaining_moves_label.text = "x" + ("%0*d" % [2, time_left])
	bonus_moves_label.text = "+" + str(bonus_time)
	bonus_moves_label.visible = bonus_time > 0

var npcs : Array[NPC]
func register_npc(npc : NPC) -> void:
	npcs.append(npc)

func kill_npcs() -> void:
	var is_mission_cleared : bool = true
	for npc in npcs:
		if npc.kill_npc():
			is_mission_cleared = false
	
	if Player.instance.kill_player():
		is_mission_cleared = false
	
	if is_mission_cleared:
		target_scene = GlobalManager.get_next_scene()
		animator.play("clear")
	
	emit_signal("killing_characters")
