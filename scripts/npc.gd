@tool
extends Node2D

@export_tool_button("Update Direction") var direction_func = update_direction

@export var sprite : Sprite2D
@export var animator : AnimationPlayer
@export var is_facing_right : bool
var has_mask : bool

func update_direction() -> void:
	if sprite != null:
		sprite.flip_h = is_facing_right

func on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	has_mask = true
	animator.play("happy")
