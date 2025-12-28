extends Node

@export var animator : AnimationPlayer
@export var burn_sfx : AudioStreamPlayer

func on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	animator.play("defuse")
	burn_sfx.play()
	
	var current_mask : MaskResource = area.get_parent().get_held_mask()
	if current_mask == null:
		GameManager.instance.force_timeout()
		GameManager.instance.connect("killing_characters", Callable(area.get_parent(), "force_kill_player"))
		return
	
	# Burn the player's held mask
	area.get_parent().set_held_mask(null)
	
	if current_mask.mask_type != MaskResource.MASK_TYPES.CURSED:
		GameManager.instance.add_bonus_time()
