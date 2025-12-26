@tool
extends Node2D
class_name GridManager

static var instance : GridManager

const TILE_SIZE = 100
const TILE_OFFSET = Vector2.ONE * TILE_SIZE * 0.5

@export_tool_button("Generate Grid")
var generate = setup_grid
@export var grid_size : Vector2i
@export var grid_rect : TextureRect

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	instance = self


func setup_grid() -> void:
	if grid_rect == null:
		return
	
	grid_rect.size = TILE_SIZE * (grid_size as Vector2)

func clamp_position(pos : Vector2) -> Vector2:
	pos.x = clamp(pos.x, 0, grid_size.x - 1)
	pos.y = clamp(pos.y, 0, grid_size.y - 1)
	pos = pos.round()
	return pos
