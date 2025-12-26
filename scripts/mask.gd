@tool
extends Node2D
class_name Mask

@export_tool_button("Update Sprite") var update = update_sprite;
@export var resource : MaskResource
@export var sprite : Sprite2D

func _enter_tree() -> void:
	update_sprite()

func update_sprite() -> void:
	if resource == null:
		sprite.texture = null
		return
	sprite.texture = resource.texture

# Pick-up logic
func on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	if area.get_parent().get_held_mask() != null:
		return
	
	area.get_parent().set_held_mask(resource)
	visible = false
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
