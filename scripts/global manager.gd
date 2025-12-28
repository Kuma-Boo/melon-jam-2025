extends Node

var level_list : Array = [
	"res://scene/levels/level1.tscn",
	"res://scene/levels/level2.tscn",
	"res://scene/levels/level3.tscn",
	"res://scene/levels/level4.tscn",
	"res://scene/levels/level5.tscn",
	"res://scene/levels/level6.tscn",
	"res://scene/levels/level7.tscn",
	"res://scene/levels/level8.tscn",
	"res://scene/levels/level9.tscn",
	"res://scene/levels/level10.tscn",
	"res://scene/levels/level11.tscn",
	"res://scene/levels/level12.tscn",
	"res://scene/levels/level13.tscn",
	"res://scene/levels/level14.tscn",
	"res://scene/levels/level15.tscn"
]

var current_level_index : int
var is_level_select : bool

func update_current_level_index() -> void:
	current_level_index = level_list.find(get_tree().current_scene.get_scene_file_path())

func get_next_scene() -> String:
	if is_level_select:
		return "res://scene/level select.tscn"
	return get_next_level()

func get_next_level() -> String:
	current_level_index += 1
	if current_level_index >= level_list.size() || !FileAccess.file_exists(level_list[current_level_index]):
		return "res://scene/end.tscn"
	return level_list[current_level_index]
