# @tool
class_name Item extends Resource
# TODO: add description
# TODO: add use() override func
# TODO: add equip() override func
# TODO: add stats
# TODO: add tooltip() override func
# docstring


# signals

# enums

# constants

# @export vars
@export var id: int = -1
@export var name: String = "dummy"
@export var amount: int = 0
@export var stack_size: int = 64

# public vars

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
## increase item amount by [param amount_to_add]
## capped at [param stack_size]
func add(amount_to_add: int) -> void:
	amount = min(stack_size, amount + amount_to_add)


## decrease item amount by [param amount_to_remove]
## capped at 0
func remove(amount_to_remove: int) -> void:
	amount = max(0, amount - amount_to_remove)


## main function for entities to interact with item.
## will be called when item in inventory is clicked.
func use(entity: EntityProperties) -> void:
	var entity_name: String = "undefined"
	if entity:
		entity_name = entity.name
	print("%s interacting with" % [entity_name])


func save() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"amount": amount,
		"stack_size": stack_size,
	}


func load(data: Dictionary) -> void:
	id = data["id"]
	name = data["name"]
	if data.has("amount"):
		amount = data["amount"]
	if data.has("stack_size"):
		stack_size = data["stack_size"]


# private methods
func _to_string() -> String:
	return "[%d]%s: amount: %d/%d" % [id, name, amount, stack_size]


# subclasses
