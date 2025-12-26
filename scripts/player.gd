extends Node2D

@export var movement_curve : Curve
@export var sprite : Sprite2D
@export var animator : AnimationPlayer
var current_position : Vector2
var target_position : Vector2
var movement_timer : float

var state : STATE
enum STATE {
	IDLE,
	MOVING,
	TIMEOVER
}

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
	
	if Input.is_action_just_pressed("restart"):
		GameManager.instance.reload_scene()
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
	
	var movement_direction : Vector2
	if !is_zero_approx(horizontal_input):
		movement_direction = Vector2.RIGHT * sign(horizontal_input)
	else:
		movement_direction = Vector2.DOWN * sign(vertical_input)
	
	target_position = GameManager.instance.clamp_position(target_position + movement_direction)
	if current_position.is_equal_approx(target_position): # Invalid movement
		return
	
	movement_timer = 0;
	state = STATE.MOVING
	start_movement_animation(movement_direction)

func start_movement_animation(movement_direction : Vector2):
	if movement_direction.x < 0:
		sprite.flip_h = true
	elif movement_direction.x > 0:
		sprite.flip_h = false
	
	animator.seek(0.0)
	animator.play("move")

func process_movement(delta : float) -> void:
	movement_timer += delta
	var position_interpolation_value : float = movement_timer / movement_curve.max_domain
	position_interpolation_value = movement_curve.sample(position_interpolation_value)
	var lerped_position = lerp(current_position, target_position, position_interpolation_value) * GameManager.TILE_SIZE
	lerped_position += GameManager.TILE_OFFSET
	position = lerped_position
	
	if is_equal_approx(position_interpolation_value, 1.0):
		current_position = target_position
		if GameManager.instance.update_time():
			state = STATE.TIMEOVER
		else:
			state = STATE.IDLE
