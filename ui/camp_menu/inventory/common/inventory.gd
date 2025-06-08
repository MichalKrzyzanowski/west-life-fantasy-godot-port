# @tool
class_name Inventory extends Resource
# docstring


# signals
## emitted when any inventory item is updated/removed
## or a new item is added
signal on_inventory_update()
## emitted when item with [param item_id] is used
signal on_item_used(item_id: int)

# enums

# constants

# @export vars
## party reference
@export var party: Array[EntityProperties]
## dictionary that stores items, key is the items id
@export var inventory: Dictionary[int, Item] = {}

# public vars

# private vars
# TODO: think of moving to item utility class
var _item_type_callbacks: Dictionary = {
	"consumable": func() -> Consumable: return Consumable.new("consume"),
	"gear": func() -> Gear: return Gear.new(),
	"weapon": func() -> Gear: return Gear.new("equip_weapon"),
	"armour": func() -> Gear: return Gear.new("equip_armour"),
}

# @onready vars


# _init
# func _init() -> void:
# 	pass


# _enter_tree
# func _enter_tree() -> void:
# 	pass


# _ready
# func _ready() -> void:
# 	pass


# remaining builtins e.g. _process, _input


# public methods
## adds [param amount] item(s) with [param item_id]
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
	var new_item: Item = ItemDatabase.get_item(item_id).duplicate(true)
	new_item.update_item_action()

	inventory[item_id] = new_item
	inventory[item_id].add(amount)
	on_inventory_update.emit()


## populate inventory with item ids from [param item_ids]
func add_items(item_ids: Array[int]) -> void:
	for id: int in item_ids:
		add_item(id)


## removes [param amount] item(s) with [param item_id]
func remove_item(item_id: int, amount: int = 1) -> void:
	if !inventory.has(item_id):
		printerr("no item present with id %d" % item_id)
		return

	# unequip gear for party member that
	# had removed item equipped.
	for member: EntityProperties in party:
		if item_id in member.get_gear_ids():
			member.unequip_gear(item_id)
			break

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


## upgrade item with [param item_id] if applicable
## and party can afford to do so
func upgrade_item(item_id: int) -> void:
	if !inventory.has(item_id):
		printerr("no item present with id %d" % item_id)
		return

	# upgrade item only if the item has upgrade() method
	var item: Item = get_item(item_id)
	if item.has_method("upgrade"):
		item.upgrade()
		on_inventory_update.emit()

	# send out gear update signal for party member that has
	# upgraded item equipped
	for member: EntityProperties in party:
		if item_id in member.get_gear_ids():
			member.on_gear_changed.emit()
			return


## Dictionary clear() wrapper
func clear() -> void:
	inventory.clear()


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


## saves data as dictionary for JSON format
func save() -> Dictionary:
	var dict: Dictionary = {}

	for id: int in inventory.keys():
		dict[id] = inventory[id].save()

	return {
		"inventory": dict
	}


## load data from JSON savefile
func load(data: Dictionary) -> void:
	for item_data: Dictionary in data["inventory"].values():
		# TODO: think of moving below logic to item utility class
		var item: Item
		if !item_data.has("type") || !_item_type_callbacks.has(item_data["type"]):
			item = Item.new()
			item.load(item_data)
			item.update_item_action()
			inventory[item.id] = item
			continue

		item = _item_type_callbacks[item_data["type"]].call()
		item.load(item_data)
		item.update_item_action()
		inventory[item.id] = item


# private methods
## returns string representation of the inventory
func _to_string() -> String:
	return str(inventory)


# subclasses
