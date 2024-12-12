# @tool
class_name Consumable extends Item
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
## actions
func _action_consume(entity: EntityProperties) -> int:
	entity.stats.add(stats)
	return 1


# subclasses
