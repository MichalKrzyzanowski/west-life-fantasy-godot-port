# @tool
class_name Reward
extends Resource
# docstring


# signals

# enums

# constants

# @export vars
@export var item_id: int = -1
@export var party_member_index: int = -1

# public vars

# private vars

# @onready vars


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


# func _ready() -> void:
# 	pass


# remaining builtins e.g. _process, _input


# public methods
## adds item with [member item_id] to appropriate party inventory.
## if [member party_member_index] == -1, 
## item defaults to [member InventoryManager.consumables inventory]
func earn() -> void:
	if party_member_index == -1:
		InventoryManager.consumables_inventory.add_item(item_id)
		return

	InventoryManager.get_party_inventory(party_member_index).add_item(item_id)


## saves data as dictionary for JSON format
func save() -> Dictionary:
	return {
		"item_id": item_id,
		"party_member_index": party_member_index,
	}


## load data from JSON savefile
func load(data: Dictionary) -> void:
	item_id = data["item_id"]
	party_member_index = data["party_member_index"]


# private methods


# subclasses

