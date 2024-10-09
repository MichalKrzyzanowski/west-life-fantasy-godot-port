# @tool
class_name Inventory extends Resource
# docstring


# signals

# enums

# constants

# @export vars

# public vars
var inventory: Dictionary

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


# public methods
func add_item(item_id: int, amount: int) -> void:
	var new_item: Item = ItemDatabase.get_item(item_id)
	if !new_item:
		printerr("item with id %d not available in database" % item_id)
		return

	if inventory.has(item_id):
		inventory[item_id].add(amount)
	else:
		inventory[item_id] = new_item


func remove_item(item_id: int, amount: int) -> void:
	if inventory.has(item_id):
		# should always be negative amount
		inventory[item_id].add(amount)
		if inventory[item_id].amount > 0:
			return
	inventory.erase(item_id)


# private methods


# subclasses
