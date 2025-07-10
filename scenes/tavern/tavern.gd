# @tool
# class_name name
extends Node2D
# docstring


# signals

# enums

# constants
## all keys that can be randomly displayed onscreen
const KEYCODES: Array[int] = [
	KEY_A,
	KEY_W,
	KEY_S,
	KEY_D,
]

# @export vars

# public vars

# private vars
var _current_keycode: int = 0

# @onready vars
@onready var button_label: Label = $UI/ButtonLabel
@onready var key_switch_timer: Timer = $KeySwitchTimer
@onready var player: Control = $UI/TavernPlayer


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


## randomize onscreen key
func _ready() -> void:
	_change_key_random()
	player.on_correct_key_pressed.connect(_change_key_random)


# remaining builtins e.g. _process, _input


# public methods


# private methods
## changes key that is displayed on the screen everytime [signal key_switch_timer.timeout]
## is emitted
func _change_key_random() -> void:
	_current_keycode = KEYCODES[randi_range(0, KEYCODES.size() - 1)]
	button_label.text = OS.get_keycode_string(_current_keycode)

	if key_switch_timer.is_inside_tree():
		key_switch_timer.start()


func _on_key_switch_timer_timeout() -> void:
	_change_key_random()


# subclasses
