extends Node2D

@export var movement_curve : Curve
var current_position : Vector2
var target_position : Vector2
var movement_timer : float

var state : STATE
enum STATE {
	IDLE,
	MOVING
}

func _ready():
	current_position = get_starting_position()
	target_position = current_position
	position = current_position * GridManager.TILE_SIZE + GridManager.TILE_OFFSET

func get_starting_position() -> Vector2:
	var pos : Vector2 = (position - GridManager.TILE_OFFSET)
	pos /= GridManager.TILE_SIZE as float
	pos = round(pos)
	return pos

func _process(delta: float) -> void:
	if state == STATE.IDLE:
		check_movement_inputs()
	else:
		process_movement(delta)

func check_movement_inputs() -> void:
	var horizontal_input : float = Input.get_axis("move_left", "move_right");
	var vertical_input : float = Input.get_axis("move_up", "move_down");
	if is_zero_approx(horizontal_input) && is_zero_approx(vertical_input):
		return
	
	if !is_zero_approx(horizontal_input):
		target_position += Vector2.RIGHT * sign(horizontal_input)
	else:
		target_position += Vector2.DOWN * sign(vertical_input)
	
	target_position = GridManager.instance.clamp_position(target_position)
	if current_position.is_equal_approx(target_position): # Invalid movement
		return
	
	state = STATE.MOVING
	movement_timer = 0;

func process_movement(delta : float) -> void:
	movement_timer += delta
	var position_interpolation_value : float = movement_timer / movement_curve.max_domain
	position_interpolation_value = movement_curve.sample(position_interpolation_value)
	var lerped_position = lerp(current_position, target_position, position_interpolation_value) * GridManager.TILE_SIZE
	lerped_position += GridManager.TILE_OFFSET
	position = lerped_position
	
	if is_equal_approx(position_interpolation_value, 1.0):
		current_position = target_position
		state = STATE.IDLE
