# @tool
class_name MainQuest
extends Quest
# docstring


# signals

# enums

# constants

# @export vars
@export_enum("Blue", "Red", "Orange", "Black") var orb: int = 0

# public vars

# private vars

# @onready vars


# func _init() -> void:


# func _enter_tree() -> void:
# 	pass


# func _ready() -> void:
# 	pass


# remaining builtins e.g. _process, _input


# public methods
## saves data as dictionary for JSON format
func save() -> Dictionary:
	var dict: Dictionary = super()
	dict["orb"] = orb
	dict["type"] = "main"

	return dict


## load data from JSON savefile
func load(data: Dictionary) -> void:
	super(data)
	orb = data["orb"]


# private methods
## updates quest status such as state, adding rewards, etc.
## updates [member PartyManager.orbs] based on [member orb] index
## called when all tasks are completed
func _update_quest_status() -> void:
	PartyManager.update_orb(orb, true)
	super()


# subclasses
