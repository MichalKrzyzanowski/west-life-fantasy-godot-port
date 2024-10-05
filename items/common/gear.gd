# @tool
class_name Gear extends Item
# docstring


# signals

# enums

# constants

# @export vars
@export var combat_stats: CombatStats = CombatStats.new()

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
func load(data: Dictionary) -> void:
	super(data)
	if data.has("combat_stats"):
		combat_stats.load(data["combat_stats"])


# private methods
func _to_string() -> String:
	return super() + " %s" % combat_stats


# subclasses


