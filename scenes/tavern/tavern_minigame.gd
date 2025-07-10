# @tool
# class_name name
extends Control
# docstring


# signals
## emitted when correct key is pressed by player
signal on_correct_key_pressed()

# enums

# constants
## target level to reach in order to win
const TARGET_LEVEL: int = 3
## color to fill level boxes upon filling out the progress bar
const LEVEL_CLEAR_COLOR: Color = Color.GREEN

# @export vars
## reference to oncreen button
@export var button_label: Label
## path to credits scene
@export var credits_scene_path: NodePath
## player name
@export var player_name: String = ""
## progress gain when correct key is pressed
@export var player_step: float = 10.0

## cpu related options
@export_group("cpu")
## set this if the player should be controlled by the cpu
@export var is_cpu: bool = false
## how long the cpu takes in seconds to make a decision
@export var cpu_decision_interval: float = 0.75
## how much progress the cpu games when guessing correctly
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


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


## initializes tavern player's name, onscreen button reference
## and cpu status
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
## checks if player pressed key that is displayed onscreen
## and punishes player if incorrect key is pressed
func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_pressed():
		if event.keycode == OS.find_keycode_from_string(button_label.text):
			_add_progress(player_step)
			on_correct_key_pressed.emit()
			return

		# reduce player progress bar and prevent any input for
		# a short time
		_add_progress(-player_step)
		_stun()


# func _process(delta: float) -> void:
# 	pass


# public methods


# private methods
## disables player input
func _stun() -> void:
	set_process_input(false)
	stun_timer.start()


## increases value in progress bar by [param step].
## checks if level should be gained i.e. fill out one of three boxes
func _add_progress(step: float) -> void:
	progress_bar.value += step

	if progress_bar.value >= progress_bar.max_value:
		_gain_level()


## fill out one of three boxes i.e. levels.
## if [constant TARGET_LEVEL] is reached, game switches to
## credits scene
func _gain_level() -> void:
	if _current_level >= TARGET_LEVEL:
		return

	progress_boxes.get_child(_current_level).self_modulate = LEVEL_CLEAR_COLOR
	_current_level += 1

	# only switch to credits scene if target level is reached
	# and credits scene is valid
	if _current_level == TARGET_LEVEL && _credits_scene:
		get_tree().change_scene_to_packed(_credits_scene)

	progress_bar.value = progress_bar.min_value


## disables stun on player
func _on_stun_timer_timeout() -> void:
	set_process_input(true)


## makes cpu decision which is always guessing correctly
func _on_cpu_decision_timer_timeout() -> void:
	_add_progress(cpu_progress_step)

	if cpu_decision_timer.is_inside_tree():
		cpu_decision_timer.start()


# subclasses
