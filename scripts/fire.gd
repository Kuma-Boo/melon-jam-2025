extends Node

@export var explosion_vfx : GPUParticles2D

func on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	# Burn the player's held mask
	area.get_parent().set_held_mask(null)
	explosion_vfx.restart()
