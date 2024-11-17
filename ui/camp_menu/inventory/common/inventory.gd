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
	var new_item: Item = ItemDatabase.get_item(item_id).duplicate()
	if !new_item:
		printerr("item with id %d not available in database" % item_id)
		return

	if !inventory.has(item_id):
		inventory[item_id] = new_item
	inventory[item_id].add(amount)

	on_inventory_update.emit()


func remove_item(item_id: int, amount: int = 1) -> void:
	if inventory.has(item_id):
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


func use_item(item_id: int) -> void:
	var current_item: Item = get_item(item_id)

	# bool in integer form, needed for bit &
	var consume_item: int = 1

	if party.size() > 0:
		for member: EntityProperties in party:
			consume_item &= current_item.use(member)

	on_item_used.emit(item_id)
	# return code above 0 means that the item was used up
	# i.e. removed
	if consume_item:
		remove_item(item_id)
		on_inventory_update.emit()


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
