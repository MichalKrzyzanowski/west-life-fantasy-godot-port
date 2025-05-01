# @tool
class_name Item extends Resource
# docstring


# signals

# enums

# constants

# @export vars
## item id
@export var id: int = -1
## item name
@export var name: String = "dummy"
## item type, used for inventory item filtering
@export var type: String = ""
## count of items in the stack
@export var amount: int= 0
## max amount of an item an inventory can hold
@export var stack_size: int = 64
## item description, mainly used for consumables
@export var description: String = "dummy"
## item action method identifier, used in [member item_action]
@export var item_action_name: String = "dummy"

# public vars
## action to call when item is used
## allows items to have functionality such as
## healing, increasing max hp, etc. on use
var item_action: Callable

# private vars

# @onready vars


# _init
## initilizes item action identifier
func _init(new_item_action_name: String = "") -> void:
	if !new_item_action_name:
		return

	# var final_action_name: String = "_action_%s" % new_item_action_name
	item_action_name = "_action_%s" % new_item_action_name


# _enter_tree
# func _enter_tree() -> void:
# 	pass


# _ready
# func _ready() -> void:
# 	pass


# remaining builtins e.g. _process, _input


# public methods
## creates a callable to the correct action, if exists,
## based on [member Item.item_action_name]
func update_item_action() -> void:
	if has_method(item_action_name):
		print("has method %s" % item_action_name)
		item_action = Callable(self, item_action_name)
	else:
		print("no method found %s" % item_action_name)


## increase item amount by [param amount_to_add]
## capped at [param stack_size]
func add(amount_to_add: int = 1) -> void:
	amount = min(stack_size, amount + amount_to_add)


## decrease item amount by [param amount_to_remove]
## capped at 0
func remove(amount_to_remove: int = 1) -> void:
	amount = max(0, amount - amount_to_remove)


## main function for entities to interact with item.
## will be called when item in inventory is clicked.
## returns: 0 = item not used up, 1+: item used up
func use(entity: EntityProperties) -> int:
	if !item_action:
		printerr("item action is null")
		return -1
	return item_action.call(entity)


## saves data as dictionary for JSON format
func save() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"type": type,
		"amount": amount,
		"stack_size": stack_size,
		"description": description,
	}


## load data from JSON savefile
func load(data: Dictionary) -> void:
	id = data["id"]
	name = data["name"]
	if data.has("amount"):
		amount = data["amount"]
	if data.has("stack_size"):
		stack_size = data["stack_size"]
	if data.has("description"):
		description = data["description"]
	if data.has("type"):
		type = data["type"]


# private methods
## string representation of Item class
func _to_string() -> String:
	return "[%d]%s: amount: %d/%d" % [id, name, amount, stack_size]


# subclasses
