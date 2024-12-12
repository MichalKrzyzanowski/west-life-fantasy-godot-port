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


func get_party_inventories() -> Array[Inventory]:
	return _party_inventories


func add_party_inventory(inventory: Inventory) -> void:
	_party_inventories.append(inventory)


# TODO: test func, remove after testing
func test_populate_inventories(generate_party: bool = false) -> void:
	if generate_party:
		var mem1 = load("res://entities/party-members/black_belt/black_belt.tres")
		var mem2 = load("res://entities/party-members/fighter/fighter.tres")
		var mem3 = load("res://entities/party-members/black_mage/black_mage.tres")
		var mem4 = load("res://entities/party-members/thief/thief.tres")
		PartyManager.add_member(mem1)
		create_party_inventory()
		PartyManager.add_member(mem2)
		create_party_inventory()
		PartyManager.add_member(mem3)
		create_party_inventory()
		PartyManager.add_member(mem4)
		create_party_inventory()

	# setup consumables
	consumables_inventory = Inventory.new()
	consumables_inventory.add_item(1, 5)
	consumables_inventory.add_item(2, 5)
	consumables_inventory.add_item(3, 5)

	# setup party equip
	for i: Inventory in _party_inventories:
		i.add_item(31)
		i.add_item(32)
		i.add_item(21)
		i.add_item(22)


# private methods
func _inventory_exists(index: int) -> bool:
	return index < _party_inventories.size()


# subclasses
