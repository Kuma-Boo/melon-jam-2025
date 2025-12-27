extends Node

@export var explosion_vfx : GPUParticles2D
@export var animator : AnimationPlayer

func on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	if area.get_parent().get_held_mask() == null:
		return
	
	# Burn the player's held mask
	area.get_parent().set_held_mask(null)
	explosion_vfx.restart()
	animator.play("defuse")
