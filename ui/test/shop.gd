# @tool
# class_name name
extends Panel
# docstring


# signals

# enums

# constants

# @export vars
## temporary gold
@export var gold: int = 100

# public vars
var item_list: Dictionary

# private vars

# subclasses

# @onready vars
@onready var item_select := $ItemSelect as OptionButton
@onready var amount_edit := $AmountEdit
@onready var sell_toggle := $CheckBox
@onready var modify_item_button := $ModifyItemButton
@onready var item_database: Node = %ItemDatabase


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	if item_database:
		for item in item_database.item_database:
			item_select.add_item(item_database.item_database[item].name, item)


# remaining builtins e.g. _process, _input


# public methods


# private methods
func _add_item(item_id: int, amt: int) -> void:
	# append amount if item is already present
	if item_list.has(item_id):
		item_list[item_id].add(amt)
		return

	var new_item: Item = item_database.item_database[item_id].duplicate()
	new_item.add(amt)
	item_list[item_id] = new_item


func _remove_item(item_id: int, amt: int) -> void:
	if item_list.has(item_id):
		item_list[item_id].add(amt)
		if item_list[item_id].amount > 0:
			return
	item_list.erase(item_id)

# subclasses


func _on_modify_item_button_up() -> void:
	if !item_list:
		print("no inventory set")
		return

	var item_id: int = item_select.get_item_id(item_select.selected)
	print("selected item id: %d" % item_id)
	if item_id == -1:
		print("select a valid item")
		return

	var amount: int = amount_edit.value
	var sell_mode_active: bool = sell_toggle.button_pressed

	if sell_mode_active:
		_remove_item(item_id, amount)
	else:
		_add_item(item_id, amount)
	# print("inventory:")
	# for item: Item in item_list:
	# 	print("%s: %d/%d" % [item.name, item_list[item].amount, item_list[item].stack_size])


func _on_check_box_toggled(toggled_on: bool) -> void:
	modify_item_button.text = "Sell Item" if toggled_on else "Buy Item"
