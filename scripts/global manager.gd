extends Node

var level_list : Array = [
	"res://scene/levels/level1.tscn",
	"res://scene/levels/level2.tscn",
	"res://scene/levels/level3.tscn",
	"res://scene/levels/level4.tscn",
	"res://scene/levels/level5.tscn",
]

var current_level_index : int

func update_current_level_index() -> void:
	current_level_index = level_list.find(get_tree().current_scene)

func get_next_level() -> String:
	current_level_index += 1
	if current_level_index >= level_list.size():
		return ""
	return  level_list[current_level_index]
