@tool
extends Control
class_name GameManager

static var instance : GameManager

const TILE_SIZE = 100
const TILE_OFFSET = Vector2.ONE * TILE_SIZE * 0.5

@export_tool_button("Generate Grid") var generate = setup_grid
@export var grid_size : Vector2i
@export var grid_rect : TextureRect

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	
	instance = self
	time_left = level_start_time
	transition_animator.play("fade-in")
	transition_animator.advance(0.0)

func setup_grid() -> void:
	if grid_rect != null:
		grid_rect.size = TILE_SIZE * (grid_size as Vector2)

func clamp_position(pos : Vector2) -> Vector2:
	pos.x = clamp(pos.x, 0, grid_size.x - 1)
	pos.y = clamp(pos.y, 0, grid_size.y - 1)
	pos = pos.round()
	return pos

@export var transition_animator : AnimationPlayer
static var is_transition_active : bool
func reload_transition() -> void:
	is_transition_active = true
	transition_animator.play("fade-out")

func finish_transition() -> void:
	is_transition_active = false

func reload_scene() -> void:
	get_tree().reload_current_scene()

func spirit_transition() -> void:
	is_transition_active = true
	transition_animator.play("spirit");

@export var level_start_time : int
@export var time_interface_head : Sprite2D
var time_left : int
const max_head_position = 380;

func update_time() -> bool:
	time_left -= 1
	var target_head_position = lerp(max_head_position, 0, time_left / (level_start_time as float));
	time_interface_head.position = Vector2(target_head_position, time_interface_head.position.y)
	return time_left == 0

var npcs : Array[NPC]
func register_npc(npc : NPC) -> void:
	npcs.append(npc)

func kill_npcs() -> void:
	for npc in npcs:
		npc.kill_npc()
	
	Player.instance.kill_player()
