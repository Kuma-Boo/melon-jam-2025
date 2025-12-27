@tool
extends Node2D
class_name Mask

@export_tool_button("Update Sprite") var update = update_sprite;
@export var resource : MaskResource
@export var sprite : Sprite2D
@export var use_desire_sprite : bool

func _enter_tree() -> void:
	update_sprite()

func update_sprite() -> void:
	if resource == null:
		sprite.texture = null
		return
	
	if use_desire_sprite:
		sprite.texture = resource.desire_texture
	else:
		sprite.texture = resource.texture

# Pick-up logic
func on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	var new_mask : MaskResource = area.get_parent().get_held_mask()
	if new_mask != null && new_mask.mask_type == MaskResource.MASK_TYPES.CURSED:
		return
	
	area.get_parent().set_held_mask(resource)
	resource = new_mask
	update_sprite()
	
	if new_mask != null:
		return
	
	visible = false
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
