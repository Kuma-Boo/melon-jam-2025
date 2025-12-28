extends Node

@export var animator : AnimationPlayer
@export var burn_sfx : AudioStreamPlayer
@export var flame_material : ShaderMaterial

var shader_time : float
const SHADER_ROLLOVER : float = 3600;
const TIME_PARAMETER : StringName = "time";

# Because Web Exports are stupid
func _process(delta: float) -> void:
	shader_time += delta
	if shader_time > SHADER_ROLLOVER:
		shader_time -= SHADER_ROLLOVER
	flame_material.set_shader_parameter(TIME_PARAMETER, shader_time)

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
