extends Node2D
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	var m = get_node("BlackMage")
	PartyManager.party.append(m)


# remaining builtins e.g. _process, _input


# public methods


# private methods


# subclasses

