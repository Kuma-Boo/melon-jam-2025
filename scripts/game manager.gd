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
@export var grid_rect : TextureRect

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

func update_level_text() -> void:
	var level_text : String = get_tree().current_scene.get_scene_file_path()
	var level_text_array = level_text.split("/")
	level_text = level_text_array[level_text_array.size() - 1].replace(".tscn", "")
	level_text = level_text.replace("level", "LEVEL ")
	level_label.text = level_text

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

@export var level_start_time : int
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
	bonus_time = 5

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
		target_scene = GlobalManager.get_next_level()
		animator.play("clear")
	
	emit_signal("killing_characters")
