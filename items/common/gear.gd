# @tool
class_name Gear extends Item
# docstring


# signals

# enums

# constants

# @export vars
@export var stats: CombatStats = CombatStats.new()

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
	if data.has("stats"):
		stats.load(data["stats"])


func use(entity: EntityProperties) -> int:
	# TODO: add equip func
	return 0


# private methods
func _to_string() -> String:
	return super() + " %s" % stats


# subclasses


