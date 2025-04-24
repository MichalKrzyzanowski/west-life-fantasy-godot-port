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
@onready var amount_label: Label = $AmountLabel


# func _init() -> void:


# func _enter_tree() -> void:


# func _ready() -> void:


# remaining builtins e.g. _process, _input


# public methods


# private methods
func _update_amount_label() -> void:
	if item == null:
		return

	if !amount_label:
		amount_label = $AmountLabel

	button.text = item.name.capitalize()
	if item.stack_size == 1:
		amount_label.hide()
		return

	amount_label.show()
	amount_label.text = "x%d" % item.amount


func _set_defaults() -> void:
	super()
	if !amount_label:
		amount_label = $AmountLabel

	amount_label.hide()


# subclasses
