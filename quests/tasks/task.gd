# @tool
class_name Task
extends Resource
# docstring


# signals
## emitted when task is completed
signal on_task_complete()

# enums

# constants

# @export vars
## task description
@export var description: String

# public vars

# private vars

# @onready vars


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


# func _ready() -> void:
# 	pass


# remaining builtins e.g. _process, _input


# public methods
## to be overriden, used for setting default description of task
## e.g. slay x entity, deliver x item
func set_default_description() -> void:
	pass


## to be overriden, used for checking if entity, item, etc.
## matches the current target
func check_completion(_target: Variant) -> void:
	pass


# private methods
## task string representation
func _to_string() -> String:
	return description


# subclasses

