@tool
extends Node2D

@export_tool_button("Update Editor") var update = update_editor
@export var number_of_passes : int

@export_group("Components")
@export var pass_through_label : Label
@export var animator : AnimationPlayer

@export_group("Sound Effects")
@export var fall_sfx : AudioStreamPlayer
@export var tick_sfx : AudioStreamPlayer

var is_active : bool

func update_editor() -> void:
	pass_through_label.text = str(number_of_passes)

func _enter_tree() -> void:
	update_editor()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	animator.play("init")
	pass_through_label.text = str(number_of_passes)

func on_area_entered(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	if is_active:
		area.get_parent().cancel_movement()

func on_area_exited(area: Area2D) -> void:
	if !area.is_in_group("player"):
		return
	
	if is_active:
		return
	
	number_of_passes -= 1
	pass_through_label.text = str(number_of_passes)
	if number_of_passes > 0:
		tick_sfx.play()
		return
	
	is_active = true
	animator.play("grow")
	fall_sfx.play()
