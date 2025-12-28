@tool
extends Node2D
class_name Player

static var instance : Player

@export_tool_button("Editor Update") var editor_update = initialize
@export var starting_mask : MaskResource

@export_group("Components")
@export var mask : Mask
@export var movement_curve : Curve
@export var visual_root : Node2D
@export var animator : AnimationPlayer

@export_group("Sound Effects")
@export var move_sfx : AudioStreamPlayer
@export var hit_wall_sfx : AudioStreamPlayer
@export var pickup_mask_sfx : AudioStreamPlayer

var current_position : Vector2
var target_position : Vector2
var movement_timer : float
var last_input_direction : Vector2
var last_movement_direction : Vector2
var consecutive_movement_amount : int
var is_facing_right : bool = true

var state : STATE
enum STATE {
	IDLE,
	MOVING,
	TIMEOVER
}

func _enter_tree() -> void:
	initialize()
	if Engine.is_editor_hint():
		return
	
	instance = self

func _ready():
	if Engine.is_editor_hint():
		return
	
	current_position = get_starting_position()
	target_position = current_position
	position = current_position * GameManager.TILE_SIZE + GameManager.TILE_OFFSET
	get_parent().call_deferred("move_child", self, get_parent().get_child_count() - 1) # Fix z-indexing

func initialize() -> void:
	set_held_mask(starting_mask, false)

func get_starting_position() -> Vector2:
	var pos : Vector2 = (position - GameManager.TILE_OFFSET)
	pos /= GameManager.TILE_SIZE as float
	pos = round(pos)
	return pos

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	process_space_sharing(delta)
	
	if state == STATE.TIMEOVER:
		return
	
	process_inputs()
	
	if state == STATE.IDLE:
		check_movement_inputs()
	elif state == STATE.MOVING:
		process_movement(delta)

var space_share_direction : int
const SPACE_SHARE_SMOOTHING : float = 500.0
func process_space_sharing(delta : float) -> void:
	var target_space_share_position = space_share_direction * Vector2.RIGHT * GameManager.SPACE_SHARE_AMOUNT
	visual_root.position = visual_root.position.move_toward(target_space_share_position,  SPACE_SHARE_SMOOTHING * delta)

func set_space_share_direction(direction : int) -> void:
	space_share_direction = direction

var prioritize_horizontal_inputs : bool
func process_inputs() -> void:
	if Input.is_action_just_pressed("move_left") || Input.is_action_just_pressed("move_right"):
		prioritize_horizontal_inputs = true
	elif Input.is_action_just_pressed("move_up") || Input.is_action_just_pressed("move_down"):
		prioritize_horizontal_inputs = false
	
	var horizontal_input : int = sign(Input.get_axis("move_left", "move_right"));
	var vertical_input : int = sign(Input.get_axis("move_up", "move_down"));
	if abs(horizontal_input) > abs(vertical_input) || (horizontal_input != 0 && prioritize_horizontal_inputs):
		last_input_direction = Vector2.RIGHT * horizontal_input
	elif abs(horizontal_input) < abs(vertical_input) || (vertical_input != 0 && !prioritize_horizontal_inputs):
		last_input_direction = Vector2.DOWN * vertical_input
	else:
		last_input_direction = Vector2.ZERO
	
	if !GameManager.is_transition_active && Input.is_action_just_pressed("restart_level"):
		GameManager.instance.reload_transition()

func check_movement_inputs() -> void:
	if last_input_direction.is_zero_approx():
		return
	
	if !is_zero_approx(last_input_direction.x):
		last_movement_direction = Vector2.RIGHT * sign(last_input_direction.x)
	else:
		last_movement_direction = Vector2.DOWN * sign(last_input_direction.y)
	
	move()

func move() -> void:
	target_position = GameManager.instance.clamp_position(target_position + last_movement_direction)
	if current_position.is_equal_approx(target_position): # Invalid movement
		if consecutive_movement_amount != 0:
			finish_movement()
		return
	
	movement_timer = 0
	movement_direction = 1
	state = STATE.MOVING
	start_movement_animation(sign(last_movement_direction.x))
	move_sfx.play()

func start_movement_animation(input_direction : int):
	if !is_zero_approx(input_direction):
		visual_root.scale.x = input_direction
	
	if input_direction > 0:
		is_facing_right = true
	elif input_direction < 0:
		is_facing_right = false
	
	animator.seek(0.0)
	animator.play("move")

func finish_movement():
	is_mask_just_picked_up = false
	start_idle()
	if consecutive_movement_amount != 0:
		advance_time()
	consecutive_movement_amount = 0

func advance_time():
	if GameManager.instance.update_time():
		state = STATE.TIMEOVER
		GameManager.instance.spirit_transition()

var movement_direction : int
func process_movement(delta : float) -> void:
	movement_timer += delta * movement_direction
	var position_interpolation_value : float = movement_timer / movement_curve.max_domain
	position_interpolation_value = movement_curve.sample(position_interpolation_value)
	var lerped_position = lerp(current_position, target_position, position_interpolation_value) * GameManager.TILE_SIZE
	lerped_position += GameManager.TILE_OFFSET
	position = lerped_position
	
	if (is_zero_approx(position_interpolation_value) && movement_direction < 0) || (is_equal_approx(position_interpolation_value, 1.0) && movement_direction > 0):
		if movement_direction < 0:
			finish_movement()
			target_position = current_position
			return
		
		current_position = target_position
		consecutive_movement_amount += 1
		
		if mask.resource != null && mask.resource.mask_type == MaskResource.MASK_TYPES.RABBIT:
			if consecutive_movement_amount < 2 && !is_mask_just_picked_up:
				state = STATE.IDLE
				move()
				return
		
		finish_movement()

func start_idle():
	state = STATE.IDLE
	animator.play("idle")

func cancel_movement() -> void:
	movement_direction = -1
	hit_wall_sfx.play()

var is_mask_just_picked_up : bool
func get_held_mask() -> MaskResource:
	return mask.resource

func set_held_mask(new_mask : MaskResource, play_sfx : bool = true) -> void:
	if !Engine.is_editor_hint():
		is_mask_just_picked_up = true
	
	if play_sfx && new_mask != null:
		pickup_mask_sfx.play()
	
	mask.resource = new_mask
	mask.update_sprite()

func kill_player() -> bool:
	if mask.resource != null && mask.resource.mask_type == MaskResource.MASK_TYPES.CURSED:
		force_kill_player()
		return true
	return false

func force_kill_player() -> void:
	animator.play("dead")
	animator.advance(0.0)
	animator.play("idle")
