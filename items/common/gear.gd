# @tool
class_name Gear extends Item
# docstring


# signals

# enums

# constants

# @export vars
## gear stats
@export var stats: CombatStats = CombatStats.new()

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
	dict["stats"] = stats.save()

	return dict


## load data from JSON savefile
func load(data: Dictionary) -> void:
	super(data)
	if data.has("stats"):
		stats.load(data["stats"])


## handles logic for upgrading gear
func upgrade() -> void:
	if stats.has_reached_max_level():
		print("%s is max level" % name)
		return
	elif !PartyManager.can_afford(stats.gold_level_cost):
		print("cannot afford %s upgrade. cost: %d, gold: %d" % [
				name, stats.gold_level_cost, PartyManager.gold
		])
		return

	# spend party gold and upgrade
	PartyManager.spend_gold(stats.gold_level_cost)
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
