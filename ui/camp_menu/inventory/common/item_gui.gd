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

		_current_item_name = item.name.capitalize()
		update_item_equip()
		update_item_level()
		update_item_amount()

		update_label_text()


# private vars
var _current_item_name: String = default_name

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


func update_label_text() -> void:
	text = _current_item_name


# private methods
func _set_defaults() -> void:
	_current_item_name = default_name
	update_label_text()


func _on_pressed() -> void:
	if !item:
		printerr("no item present, cannot send signal")
		return
	on_item_clicked.emit(item.id)


func update_item_amount() -> void:
	if item.amount > 1:
		_current_item_name += " x%d" % item.amount


func update_item_equip() -> void:
	if item is Gear && item.is_equipped:
		_current_item_name = "E:%s" % _current_item_name


func update_item_level() -> void:
	if item.stats.level > 1:
		_current_item_name = "%s + %d" % [
				_current_item_name,
				item.stats.level - 1
		]


# subclasses
