extends Control

@export var max_radius: float = 40.0
@export var deadzone: float = 0.15

@onready var base: TextureRect = $Base
@onready var knob: TextureRect = $Knob

var center: Vector2
var active_touch_index: int = -1

func _ready() -> void:
	center = base.position + (base.size / 2.0)
	_reset_knob()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var local_pos = get_global_transform_with_canvas().affine_inverse() * event.position
		if event.pressed and active_touch_index == -1:
			if (local_pos - center).length() <= base.size.x / 2.0:
				active_touch_index = event.index
				_handle_stick_movement(local_pos)
		elif not event.pressed and event.index == active_touch_index:
			_release_joystick()

	elif event is InputEventScreenDrag and event.index == active_touch_index:
		var local_pos = get_global_transform_with_canvas().affine_inverse() * event.position
		_handle_stick_movement(local_pos)

func _handle_stick_movement(pos: Vector2) -> void:
	var offset = pos - center
	if offset.length() > max_radius:
		offset = offset.normalized() * max_radius

	knob.position = (center + offset) - (knob.size / 2.0)
	var normalized_vec = offset / max_radius

	# Pass axis values to Godot's action press system
	_apply_action("move_right", max(0.0, normalized_vec.x))
	_apply_action("move_left", max(0.0, -normalized_vec.x))
	_apply_action("move_down", max(0.0, normalized_vec.y))
	_apply_action("move_up", max(0.0, -normalized_vec.y))

func _apply_action(action_name: String, strength: float) -> void:
	if strength > deadzone:
		Input.action_press(action_name, strength)
	else:
		Input.action_release(action_name)

func _release_joystick() -> void:
	active_touch_index = -1
	_reset_knob()
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("move_up")
	Input.action_release("move_down")

func _reset_knob() -> void:
	knob.position = center - (knob.size / 2.0)

# Release touches when pausing or leaving the level; never carry a held stick
# into the next game. Only clear actions when this joystick owned a touch.
func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_EXIT_TREE:
		if active_touch_index != -1 and is_node_ready():
			_release_joystick()
