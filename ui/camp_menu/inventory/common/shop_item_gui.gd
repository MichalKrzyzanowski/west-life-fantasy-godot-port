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
@onready var gold_value_label: Label = $GoldValueLabel


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input


# public methods


# private methods
## updates gold value label with default
func _set_defaults() -> void:
	super()
	gold_value_label.text = ""


## sets item's gold value to gold value label if gold value > 0
func _update_item_display() -> void:
	super()
	if item.stats.gold_value > 0:
		gold_value_label.text = str(item.stats.gold_value)


# subclasses
