extends Area2D
# docstring


# signals

# enums

# constants

# @export vars
## stats of the character, used for combat
@export var stats: CombatStats
## character name
@export var entity_name: String

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


# private methods


# subclasses

