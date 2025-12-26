extends Node2D
class_name Player

static var instance : Player

@export_group("Components")
@export var mask : Mask
@export var movement_curve : Curve
@export var visual_root : Node2D
@export var animator : AnimationPlayer

var current_position : Vector2
var target_position : Vector2
var movement_timer : float
var consecutive_movement_amount : int
var last_movement_direction : Vector2

var state : STATE
enum STATE {
	IDLE,
	MOVING,
	TIMEOVER
}

func _enter_tree() -> void:
	instance = self

func _ready():
	current_position = get_starting_position()
	target_position = current_position
	position = current_position * GameManager.TILE_SIZE + GameManager.TILE_OFFSET

func get_starting_position() -> Vector2:
	var pos : Vector2 = (position - GameManager.TILE_OFFSET)
	pos /= GameManager.TILE_SIZE as float
	pos = round(pos)
	return pos

func _process(delta: float) -> void:
	if GameManager.is_transition_active:
		return
	
	if Input.is_action_just_pressed("restart_level"):
		GameManager.instance.reload_transition()
		return
	
	if state == STATE.IDLE:
		check_movement_inputs()
	elif state == STATE.MOVING:
		process_movement(delta)
	

func check_movement_inputs() -> void:
	var horizontal_input : float = Input.get_axis("move_left", "move_right");
	var vertical_input : float = Input.get_axis("move_up", "move_down");
	if is_zero_approx(horizontal_input) && is_zero_approx(vertical_input):
		return
	
	if !is_zero_approx(horizontal_input):
		last_movement_direction = Vector2.RIGHT * sign(horizontal_input)
	else:
		last_movement_direction = Vector2.DOWN * sign(vertical_input)
	
	move()

func move() -> void:
	target_position = GameManager.instance.clamp_position(target_position + last_movement_direction)
	if current_position.is_equal_approx(target_position): # Invalid movement
		finish_movement()
		return
	
	movement_timer = 0
	movement_direction = 1
	state = STATE.MOVING
	start_movement_animation(sign(last_movement_direction.x))

func start_movement_animation(input_direction : int):
	if !is_zero_approx(input_direction):
		visual_root.scale.x = input_direction
	
	animator.seek(0.0)
	animator.play("move")

func finish_movement():
	start_idle()
	
	if GameManager.instance.update_time():
		state = STATE.TIMEOVER
		GameManager.instance.spirit_transition()
		return

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
			start_idle()
			target_position = current_position
			return
		
		current_position = target_position
		
		if mask.resource != null && mask.resource.mask_type == MaskResource.MASK_TYPES.RABBIT:
			consecutive_movement_amount += 1
			if consecutive_movement_amount < 2:
				state = STATE.IDLE
				move()
				return
		
		finish_movement()

func start_idle():
	state = STATE.IDLE
	consecutive_movement_amount = 0
	animator.play("idle")

func cancel_movement() -> void:
	movement_direction = -1

func get_held_mask() -> MaskResource:
	return mask.resource

func set_held_mask(new_mask : MaskResource) -> void:
	mask.resource = new_mask
	mask.update_sprite()

func kill_player():
	if mask.resource != null && mask.resource.mask_type == MaskResource.MASK_TYPES.CURSED:
		animator.play("dead")
		animator.advance(0.0)
		animator.play("idle")
