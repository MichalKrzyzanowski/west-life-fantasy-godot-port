# @tool
class_name Inventory extends Resource
# docstring


# signals
signal on_inventory_update()
signal on_item_used(item_id: int)

# enums

# constants

# @export vars
@export var party: Array[EntityProperties]

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
	# return if item_id is not present in database
	if !ItemDatabase.has_item(item_id):
		printerr("item with id %d not available in database" % item_id)
		return

	# add amount if item already present in inventory
	if inventory.has(item_id):
		inventory[item_id].add(amount)
		on_inventory_update.emit()
		return

	# add new item to inventory
	var new_item: Item = ItemDatabase.get_item(item_id).duplicate()
	new_item.update_item_action()

	inventory[item_id] = new_item
	inventory[item_id].add(amount)
	on_inventory_update.emit()


func remove_item(item_id: int, amount: int = 1) -> void:
	if !inventory.has(item_id):
		printerr("no item present with id %d" % item_id)
		return

	# should always be negative amount
	inventory[item_id].remove(amount)
	if inventory[item_id].amount > 0:
		on_inventory_update.emit()
		return
	inventory.erase(item_id)
	on_inventory_update.emit()


## party reference setter
func set_party_ref(party_ref: Array[EntityProperties]) -> void:
	party = party_ref


## calls [method Item.use] method on item with [param item id].
## [method Item.use] is called for each member in [member party].
## [method Item.use] return code is used for item post-use action.
## valid return codes:
## -1: error when calling [method Item.use]
## 0: do nothing
## 1: remove item, send [signal Inventory.on_inventory_update]
## 2: send [signal Inventory.on_inventory_update]
func use_item(item_id: int) -> void:
	var current_item: Item = get_item(item_id)

	var consume_item: int = 0

	if party.size() > 0:
		for member: EntityProperties in party:
			consume_item = current_item.use(member)

	on_item_used.emit(item_id)
	# use() return code is used to determine what to do with
	# the item that was used e.g. remove it?
	# TODO: maybe convert to dict
	match (consume_item):
		0:
			return
		1:
			remove_item(item_id)
			on_inventory_update.emit()
		2:
			on_inventory_update.emit()
		_:
			printerr("unknown item use return code %s" % consume_item)


## Dictionary size() wrapper
func size() -> int:
	return inventory.size()


## Dictionary values() wrapper
func values() -> Array:
	return inventory.values()


## Dictionary get() wrapper
func get_item(id: int) -> Item:
	return inventory.get(id)


## Dictionary has() wrapper
func has_item(id: int) -> bool:
	return inventory.has(id)


# private methods


# subclasses
