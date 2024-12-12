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
# func _init() -> void:
# 	pass


# _enter_tree
func _enter_tree() -> void:
	pass


# _ready
func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input


# public methods
func load(data: Dictionary) -> void:
	super(data)
	if data.has("stats"):
		stats.load(data["stats"])


# private methods
func _to_string() -> String:
	return super() + " %s" % stats


## actions
func _action_equip_weapon(entity: EntityProperties) -> int:
	printerr("equiping weapon...")
	entity.change_weapon(self)
	return 2


func _action_equip_armour(entity: EntityProperties) -> int:
	printerr("equiping armour...")
	entity.change_armour(self)
	return 2


# subclasses
