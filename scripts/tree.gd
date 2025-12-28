@tool
extends Node

@export_tool_button("Update") var update = update_visuals
@export var is_shattered : bool
@export var animator : AnimationPlayer
@export var pass_sfx : AudioStreamPlayer
@export var fall_sfx : AudioStreamPlayer

func _enter_tree() -> void:
	update_visuals()

func on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	if area.get_parent().state != Player.STATE.MOVING:
		return
	
	if is_shattered:
		return
	
	var current_mask : MaskResource = area.get_parent().get_held_mask()
	if current_mask != null && current_mask.mask_type == MaskResource.MASK_TYPES.BEAR:
		is_shattered = true
		animator.play("shatter")
		fall_sfx.play()
		return
	
	pass_sfx.play()
	animator.play("pass")
	area.get_parent().advance_time()

func update_visuals() -> void:
	if animator == null:
		return
	animator.play("shattered" if is_shattered else "RESET")
