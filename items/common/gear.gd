# @tool
class_name Gear extends Item
# docstring


# signals

# enums

# constants

# @export vars
## gear stats
@export var stats: CombatStats = CombatStats.new()
# TODO: replace with character class i.e. warrior, thief in the future
## index of party member that is required to equip this item
@export var required_party_index: int = -1

# public vars
## marked true if item is equipped
var is_equipped: bool = false

# private vars

# @onready vars


# _init
## initializes stats and item action identifier
func _init(new_item_action_name: String = "") -> void:
	stats.init(true)
	super(new_item_action_name)


# _enter_tree
# func _enter_tree() -> void:
# 	pass


# _ready
# func _ready() -> void:
# 	pass


# remaining builtins e.g. _process, _input


# public methods
## saves data as dictionary for JSON format
func save() -> Dictionary:
	var dict: Dictionary = super()
	dict["required_party_index"] = required_party_index
	dict["stats"] = stats.save()

	return dict


## load data from JSON savefile
func load(data: Dictionary) -> void:
	super(data)
	if data.has("stats"):
		stats.load(data["stats"])
	if data.has("required_party_index"):
		required_party_index = data["required_party_index"]


## handles logic for upgrading gear
func upgrade() -> void:
	if stats.has_reached_max_level():
		print("%s is max level" % name)
		return
	elif !PartyManager.can_afford(stats.gil_level_cost):
		print("cannot afford %s upgrade. cost: %d, gil: %d" % [
				name, stats.gil_level_cost, PartyManager.gil
		])
		return

	# spend party gil and upgrade
	PartyManager.spend_gil(stats.gil_level_cost)
	stats.level_up()


# private methods
func _to_string() -> String:
	return super() + " %s" % stats


# actions
## action used for equiping weapon gear for [param entity].
## return 2 simply means that [member Inventory.use] will only send out
## [signal Inventory.on_inventory_update] on item use
func _action_equip_weapon(entity: EntityProperties) -> int:
	print("equiping weapon...")
	entity.change_weapon(self)
	return 2


## action used for equiping armour gear for [param entity].
## return 2 simply means that [member Inventory.use] will only send out
## [signal Inventory.on_inventory_update] on item use
func _action_equip_armour(entity: EntityProperties) -> int:
	print("equiping armour...")
	entity.change_armour(self)
	return 2


# subclasses
