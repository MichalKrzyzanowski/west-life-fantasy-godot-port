# @tool
# class_name name
extends Button
# docstring

# TODO: add action functions for each use action:
# equip() // gear, use() // consumables

# signals
signal on_item_clicked(item_id: int)

# enums

# constants

# @export vars

# public vars
var default_name: String = "----"
var item: Item:
	set(new_item):
		item = new_item
		if item == null:
			_set_defaults()
			return

		text = item.name.capitalize()
		if item.amount > 1:
			text += " x%d" % item.amount

# private vars

# @onready vars


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	_set_defaults()


# remaining builtins e.g. _process, _input


# public methods
func set_default_name(default: String) -> void:
	default_name = default


# private methods
func _set_defaults() -> void:
	text = default_name


func _on_pressed() -> void:
	if !item:
		printerr("no item present, cannot send signal")
		return
	on_item_clicked.emit(item.id)


# subclasses
