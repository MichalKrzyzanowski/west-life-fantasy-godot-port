# @tool
# class_name name
extends "item_gui.gd"
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars
@onready var gil_value_label: Label = $GilValueLabel


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input


# public methods


# private methods
## updates gil value label with default
func _set_defaults() -> void:
	super()
	gil_value_label.text = ""


## sets item's gil value to gil value label if gil value > 0
func _update_item_display() -> void:
	super()
	if item.stats.gil_value > 0:
		gil_value_label.text = str(item.stats.gil_value)


# subclasses
