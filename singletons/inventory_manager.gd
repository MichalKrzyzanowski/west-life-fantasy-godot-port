# @tool
# class_name name
extends Node
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars
## all inventories used by party
var _inventories: Array[Inventory]

# @onready vars


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	print("ids")
	print(ItemDatabase.get_ids())


# remaining builtins e.g. _process, _input


# public methods
func get_inventory(index: int) -> Inventory:
	if !_inventory_exists(index):
		printerr("no inventory found with index: %d" % index)
		return null

	return _inventories[index]


func add_inventory(inventory: Inventory) -> void:
	_inventories.append(inventory)


# private methods
func _inventory_exists(index: int) -> bool:
	return index >= _inventories.size()


# subclasses
