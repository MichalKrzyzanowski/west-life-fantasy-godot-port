# @tool
# class_name name
extends Node
# docstring


# signals

# enums

# constants

# @export vars

# public vars
## inventory used in the items screen of camp menu
## all consumables are shared between party members
var consumables_inventory: Inventory

# private vars
## all inventories used by party
var _party_inventories: Array[Inventory]

# @onready vars


# func _init() -> void:
# 	pass


## initializes [member consumables_inventory]
func _enter_tree() -> void:
	consumables_inventory = Inventory.new()


## allows saving/loading of current scene
func _ready() -> void:
	add_to_group("persist")


# remaining builtins e.g. _process, _input


# public methods
## de initializes inventory manager
func deinit() -> void:
	consumables_inventory.clear()
	_party_inventories.clear()


## creates empty party inventory
func create_party_inventory() -> void:
	add_party_inventory(Inventory.new())


## return [class Inventory] from _party_inventories array at
## [param index]
func get_party_inventory(index: int) -> Inventory:
	if !_inventory_exists(index):
		printerr("no inventory found with index: %d" % index)
		return null

	return _party_inventories[index]


## _party_inventories getter
func get_party_inventories() -> Array[Inventory]:
	return _party_inventories


## add [param inventory] to _party_inventories
func add_party_inventory(inventory: Inventory) -> void:
	_party_inventories.append(inventory)


# TODO: test func, remove after testing or once boss rewards are implemented
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


## saves data as dictionary for JSON format
func save() -> Dictionary:
	var dict: Dictionary = {
		"name": name,
		"parent": get_parent().get_path(),
		"consumables": consumables_inventory.save(),
	}

	var party_inv_dict: Dictionary = {}
	for i: int in _party_inventories.size():
		party_inv_dict[i] = _party_inventories[i].save()

	dict["party_inventories"] = party_inv_dict
	return dict


## load data from JSON savefile
func load(data: Dictionary) -> void:
	consumables_inventory.load(data["consumables"])
	for dict: Dictionary in data["party_inventories"].values():
		var new_inventory: Inventory = Inventory.new()
		new_inventory.load(dict)
		add_party_inventory(new_inventory)


# private methods
## returns [code]true[code] if [param index]
## exists in _party_inventories
func _inventory_exists(index: int) -> bool:
	return index < _party_inventories.size()


# subclasses
