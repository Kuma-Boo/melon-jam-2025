extends Node

@export var explosion_vfx : GPUParticles2D
@export var animator : AnimationPlayer

func on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	var current_mask : MaskResource = area.get_parent().get_held_mask()
	if current_mask == null:
		return
	
	# Burn the player's held mask
	area.get_parent().set_held_mask(null)
	
	if current_mask.mask_type != MaskResource.MASK_TYPES.CURSED:
		GameManager.instance.add_bonus_time()
	
	explosion_vfx.restart()
	animator.play("defuse")
