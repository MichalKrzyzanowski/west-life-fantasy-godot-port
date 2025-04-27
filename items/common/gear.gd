# @tool
class_name Gear extends Item
# docstring


# signals

# enums

# constants

# @export vars
@export var stats: CombatStats = CombatStats.new()

# public vars
var is_equipped: bool = false

# private vars

# @onready vars


# _init
func _init(new_item_action_name: String = "") -> void:
	stats.init(true)
	super(new_item_action_name)


# _enter_tree
func _enter_tree() -> void:
	pass


# _ready
func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input


# public methods
func save() -> Dictionary:
	var dict: Dictionary = super()
	dict["stats"] = stats.save()

	return dict


func load(data: Dictionary) -> void:
	super(data)
	if data.has("stats"):
		stats.load(data["stats"])


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
	print(stats)


# private methods
func _to_string() -> String:
	return super() + " %s" % stats


## actions
func _action_equip_weapon(entity: EntityProperties) -> int:
	print("equiping weapon...")
	entity.change_weapon(self)
	return 2


func _action_equip_armour(entity: EntityProperties) -> int:
	print("equiping armour...")
	entity.change_armour(self)
	return 2


# subclasses
