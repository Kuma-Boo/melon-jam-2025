extends Node

func on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	area.get_parent().cancel_movement()
