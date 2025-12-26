extends Node2D

@export var animator : AnimationPlayer
var is_active : bool

func _ready() -> void:
	animator.play("init")

func on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	if is_active:
		area.get_parent().cancel_movement()

func on_area_exited(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	is_active = true
	animator.play("grow")
	
