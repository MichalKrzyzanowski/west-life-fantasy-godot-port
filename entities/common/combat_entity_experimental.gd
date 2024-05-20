class_name EntityProperties
extends Resource
# docstring


# signals

# enums

# constants

# @export vars
## stats of the character, used for combat
@export var stats: CombatStats
## character name
@export var name: String
@export var texture: Texture

# public vars

# private vars

# @onready vars


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	# TODO: remove this when godot devs update _init behaviour when initializing
	# after resource export
	stats.init()


# remaining builtins e.g. _process, _input


# public methods
## saves data as dictionary for JSON format
func save() -> Dictionary:
	return {
		"name": name,
		"combat_stats": stats.save(),
	}


## load data from JSON savefile
func load(data) -> void:
	name = data["name"]
	stats.load(data["combat_stats"])


# private methods


# subclasses

