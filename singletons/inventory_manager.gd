# @tool
# class_name name
extends Node
# docstring


# signals

# enums

# constants

# @export vars

# public vars
var consumables_inventory: Inventory

# private vars
## all inventories used by party
var _party_inventories: Array[Inventory]
## inventory used in the items screen of camp menu
## all consumables are shared between party members

# @onready vars


func _init() -> void:
	pass


func _enter_tree() -> void:
	consumables_inventory = Inventory.new()


func _ready() -> void:
	print("ids")
	print(ItemDatabase.get_ids())


# remaining builtins e.g. _process, _input


# public methods
func create_party_inventory() -> void:
	add_party_inventory(Inventory.new())


func get_party_inventory(index: int) -> Inventory:
	if !_inventory_exists(index):
		printerr("no inventory found with index: %d" % index)
		return null

	return _party_inventories[index]


func add_party_inventory(inventory: Inventory) -> void:
	_party_inventories.append(inventory)


# TODO: test func, remove after testing
func test_populate_inventories() -> void:
	var item_ids: Array = ItemDatabase.get_ids()
	for i in _party_inventories:
		var amount_gen: int = randi_range(0, item_ids.size() - 1)
		for n in amount_gen:
			i.add_item(item_ids[randi_range(0, item_ids.size() - 1)])

	# for consumables
	var amount_gen: int = randi_range(0, item_ids.size() - 1)
	for n in amount_gen:
		consumables_inventory.add_item(item_ids[randi_range(0, item_ids.size() - 1)])


# private methods
func _inventory_exists(index: int) -> bool:
	return index >= _party_inventories.size()


# subclasses
