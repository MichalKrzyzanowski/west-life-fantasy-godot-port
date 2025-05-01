# @tool
class_name Consumable extends Item
# docstring


# signals

# enums

# constants

# @export vars
## consumable stats, mainly used for hp
@export var stats: CombatStats = CombatStats.new()

# public vars

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


# private methods
## actions
## apply item stats to [param entity] stats i.e. heal
func _action_consume(entity: EntityProperties) -> int:
	if entity.is_alive():
		entity.stats.add(stats)
	return 1


# subclasses
