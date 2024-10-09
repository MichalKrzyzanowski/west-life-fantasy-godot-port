# @tool
# class_name name
extends Button
# docstring


# signals

# enums

# constants

# @export vars

# public vars
var item: Item:
	set(new_item):
		if new_item == null:
			_set_defaults()
			return

		item = new_item
		text = item.name
		_update_amount_label()

# private vars

# @onready vars
@onready var amount_label: Label = $AmountLabel


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	_set_defaults()


# remaining builtins e.g. _process, _input


# public methods


# private methods
func _update_amount_label() -> void:
	if item == null:
		return

	if !amount_label:
		amount_label = $AmountLabel

	text = item.name.capitalize()
	if item.stack_size == 1:
		amount_label.hide()
		return

	amount_label.show()
	amount_label.text = "x%d" % item.amount


func _set_defaults() -> void:
	text = "----"
	if !amount_label:
		amount_label = $AmountLabel

	amount_label.hide()



# subclasses
