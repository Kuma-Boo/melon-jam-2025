@tool
extends Node2D
class_name NPC

@export_tool_button("Update NPC") var editor_update = update_npc

@export_enum("Boy", "Girl") var npc_type : int = 0
@export var is_facing_right : bool
@export var initial_mask_resource : MaskResource
@export var desired_mask_resource : MaskResource

@export_group("Components")
@export var visual_root : Node2D
@export var sprite : Sprite2D
@export var mask : Mask
@export var desired_mask : Mask
@export var satisfied_mask_resource : MaskResource
@export var animator : AnimationPlayer

@export_group("Sound Effects")
@export var pickup_sfx : AudioStreamPlayer


func _enter_tree() -> void:
	update_npc()

func _ready() -> void:
	if !Engine.is_editor_hint():
		GameManager.instance.register_npc(self)

func _process(delta : float) -> void:
	if Engine.is_editor_hint():
		return
	
	process_space_sharing(delta)

func update_npc() -> void:
	if visual_root != null:
		update_direction()
	
	if animator != null:
		if Engine.is_editor_hint():
			animator.play("RESET")
			animator.advance(0.0)
		
		if npc_type == 0:
			animator.play("boy")
		else:
			animator.play("girl")
		animator.advance(0.0)
	
	if mask != null:
		mask.resource = initial_mask_resource
		mask.update_sprite()
	
	update_mask_bubble()

func update_mask_bubble() -> void:
	if desired_mask_resource == null:
		return
	
	var is_satisfied : bool = desired_mask.resource == desired_mask_resource && !Engine.is_editor_hint()
	desired_mask.resource = satisfied_mask_resource if is_satisfied else desired_mask_resource
	desired_mask.update_sprite()

func update_direction() -> void:
	visual_root.scale.x = -1 if is_facing_right else 1

func has_mask() -> bool:
	return mask.resource != null

var space_share_direction : int
const SPACE_SHARE_SMOOTHING : float = 500.0
func process_space_sharing(delta : float) -> void:
	var target_space_share_position = space_share_direction * Vector2.RIGHT * GameManager.SPACE_SHARE_AMOUNT
	visual_root.position = visual_root.position.move_toward(target_space_share_position,  SPACE_SHARE_SMOOTHING * delta)

func kill_npc() -> bool:
	if !has_mask() || mask.resource.mask_type == MaskResource.MASK_TYPES.CURSED || (desired_mask_resource != null && desired_mask_resource != mask.resource):
		animator.play("dead")
		animator.advance(0.0)
		animator.play("idle")
		return true
	
	return false

func on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	# Swap masks with the player
	var new_mask : MaskResource = area.get_parent().get_held_mask()
	
	is_facing_right = !area.get_parent().is_facing_right
	update_direction()
	space_share_direction = -1 if is_facing_right else 1
	area.get_parent().set_space_share_direction(-space_share_direction)
	
	area.get_parent().set_held_mask(mask.resource)
	mask.resource = new_mask
	mask.update_sprite()
	
	if new_mask != null && new_mask.mask_type != MaskResource.MASK_TYPES.CURSED:
		pickup_sfx.play()
		if desired_mask_resource == null || desired_mask_resource == mask.resource:
			animator.play("happy")
			update_mask_bubble()
	else:
		animator.play("idle")

func on_area_exited(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	space_share_direction = 0
	area.get_parent().set_space_share_direction(0)
