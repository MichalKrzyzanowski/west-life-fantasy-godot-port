# @tool
class_name Inventory extends Resource
# docstring


# signals

# enums

# constants

# @export vars

# public vars
var inventory: Dictionary = {}

# private vars

# @onready vars


# _init
func _init() -> void:
	pass


# _enter_tree
func _enter_tree() -> void:
	pass


# _ready
func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input
func _to_string() -> String:
	return str(inventory)


# public methods
func add_item(item_id: int, amount: int = 1) -> void:
	var new_item: Item = ItemDatabase.get_item(item_id).duplicate()
	if !new_item:
		printerr("item with id %d not available in database" % item_id)
		return

	if !inventory.has(item_id):
		inventory[item_id] = new_item
	inventory[item_id].add(amount)


func remove_item(item_id: int, amount: int = 1) -> void:
	if inventory.has(item_id):
		# should always be negative amount
		inventory[item_id].remove(amount)
		if inventory[item_id].amount > 0:
			return
	inventory.erase(item_id)


# private methods


# subclasses
