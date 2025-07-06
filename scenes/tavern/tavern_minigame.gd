# @tool
# class_name name
extends Control
# docstring


# signals
signal on_correct_key_pressed()

# enums

# constants
const TARGET_LEVEL: int = 3
const LEVEL_CLEAR_COLOR: Color = Color.GREEN

# @export vars
@export var button_label: Label
@export var credits_scene_path: NodePath
@export var player_name: String = ""
@export var player_step: float = 10.0

@export_group("cpu")
@export var is_cpu: bool = false
@export var cpu_decision_interval: float = 0.75
@export var cpu_progress_step: float = 10.0

# public vars

# private vars
var _current_level: int = 0
var _credits_scene: PackedScene

# @onready vars
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var progress_boxes: Control = $ProgressBoxes
@onready var player_label: Label = $PlayerLabel
# timers
@onready var stun_timer: Timer = $StunTimer
@onready var cpu_decision_timer: Timer = $CpuDecisionTimer


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	_credits_scene = load(credits_scene_path)
	player_label.text = player_name

	if !button_label:
		printerr("missing reference to button label")
		process_mode = Node.PROCESS_MODE_DISABLED
		return

	if is_cpu:
		set_process_input(false)
		cpu_decision_timer.wait_time = cpu_decision_interval
		cpu_decision_timer.start()


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_pressed():
		if event.keycode == OS.find_keycode_from_string(button_label.text):
			_add_progress(player_step)
			on_correct_key_pressed.emit()
			return

		_add_progress(-player_step)
		_stun()


# func _process(delta: float) -> void:
# 	pass


# public methods


# private methods
func _stun() -> void:
	set_process_input(false)
	stun_timer.start()


func _add_progress(step: float) -> void:
	progress_bar.value += step

	if progress_bar.value >= progress_bar.max_value:
		_gain_level()


func _gain_level() -> void:
	if _current_level >= TARGET_LEVEL:
		return

	progress_boxes.get_child(_current_level).self_modulate = LEVEL_CLEAR_COLOR
	_current_level += 1

	if _current_level == TARGET_LEVEL && _credits_scene:
		get_tree().change_scene_to_packed(_credits_scene)

	progress_bar.value = progress_bar.min_value


func _on_stun_timer_timeout() -> void:
	set_process_input(true)


func _on_cpu_decision_timer_timeout() -> void:
	_add_progress(cpu_progress_step)

	if cpu_decision_timer.is_inside_tree():
		cpu_decision_timer.start()


# subclasses
