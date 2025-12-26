@tool
extends Node2D
class_name NPC

@export_tool_button("Update NPC") var editor_update = update_npc

@export_enum("Boy", "Girl") var npc_type : int = 0
@export var is_facing_right : bool
@export var initial_mask : MaskResource
@export var desired_mask : MaskResource

@export_group("Components")
@export var visual_root : Node2D
@export var sprite : Sprite2D
@export var mask : Mask
@export var animator : AnimationPlayer

func _enter_tree() -> void:
	update_npc()

func _ready() -> void:
	if !Engine.is_editor_hint():
		GameManager.instance.register_npc(self)

func update_npc() -> void:
	if visual_root != null:
		if is_facing_right:
			visual_root.scale.x = -1
		else:
			visual_root.scale.x = 1
	
	if animator != null:
		if npc_type == 0:
			animator.play("boy")
		else:
			animator.play("girl")
		animator.advance(0.0)
	
	if mask != null:
		mask.resource = initial_mask
		mask.update_sprite()

func kill_npc() -> void:
	if has_mask() && mask.resource.mask_type != MaskResource.MASK_TYPES.CURSED:
		return
	
	animator.play("dead")
	animator.advance(0.0)
	animator.play("idle")

func on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	# Swap masks with the player
	var new_mask : MaskResource = area.get_parent().get_held_mask()
	
	if desired_mask != null && desired_mask != new_mask: # NPC doesn't want this mask
		return
	
	area.get_parent().set_held_mask(mask.resource)
	mask.resource = new_mask
	mask.update_sprite()
	
	if new_mask != null && new_mask.mask_type != MaskResource.MASK_TYPES.CURSED:
		animator.play("happy")
	else:
		animator.play("idle")

func has_mask() -> bool:
	return mask.resource != null
