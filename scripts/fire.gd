@tool
extends Node

@export_tool_button("Update Editor") var update = update_editor
@export_range(1, 9, 1) var number_of_sacrifices : int = 1
@export_group("Components")
@export var text_visibility : Node2D
@export var text_animator : AnimationPlayer
@export var animator : AnimationPlayer
@export var burn_sfx : AudioStreamPlayer
@export var sacrifice_label : Label
@export var flame_material : ShaderMaterial
@export var mask_bubble : Mask

var shader_time : float
const SHADER_ROLLOVER : float = 3600;
const TIME_PARAMETER : StringName = "time";

func update_editor() -> void:
	sacrifice_label.text = str(number_of_sacrifices)

func _enter_tree() -> void:
	update_editor()

# Because Web Exports are stupid
func _process(delta: float) -> void:
	shader_time += delta
	if shader_time > SHADER_ROLLOVER:
		shader_time -= SHADER_ROLLOVER
	flame_material.set_shader_parameter(TIME_PARAMETER, shader_time)

func on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	text_visibility.visible = false
	burn_sfx.play()
	
	var current_mask : MaskResource = area.get_parent().get_held_mask()
	if current_mask == null:
		animator.play("defuse")
		mask_bubble.visible = false
		GameManager.instance.force_timeout()
		GameManager.instance.connect("killing_characters", Callable(area.get_parent(), "force_kill_player"))
		return
	
	# Burn the player's held mask
	area.get_parent().set_held_mask(null)
	mask_bubble.resource = current_mask
	mask_bubble.update_sprite()
	
	number_of_sacrifices -= 1
	update_editor()
	text_animator.seek(0.0)
	text_animator.play("show")
	if number_of_sacrifices <= 0:
		animator.play("defuse")
		sacrifice_label.visible = false
	
	if current_mask.mask_type != MaskResource.MASK_TYPES.CURSED:
		GameManager.instance.add_bonus_time()
		text_visibility.visible = true
