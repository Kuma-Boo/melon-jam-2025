@tool
extends Node2D
class_name NPC

@export_tool_button("Update NPC") var editor_update = update_npc

@export_enum("Boy", "Girl") var npc_type : int = 0
@export var is_facing_right : bool
@export_group("Components")
@export var sprite : Sprite2D
@export var animator : AnimationPlayer
var has_mask : bool

func _enter_tree() -> void:
	update_npc()

func _ready() -> void:
	if !Engine.is_editor_hint():
		GameManager.instance.register_npc(self)

func update_npc() -> void:
	if sprite != null:
		sprite.flip_h = is_facing_right
	
	if animator != null:
		if npc_type == 0:
			animator.play("boy")
		else:
			animator.play("girl")
		animator.advance(0.0)

func kill_npc() -> void:
	animator.play("dead")

func on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	has_mask = true
	animator.play("happy")
