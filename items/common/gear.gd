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


# TODO: add equip funcs logic
## actions
func _action_equip_weapon(entity: EntityProperties) -> int:
	printerr("equiping weapon...")
	return 0


func _action_equip_armour(entity: EntityProperties) -> int:
	printerr("equiping armour...")
	return 0


# subclasses


