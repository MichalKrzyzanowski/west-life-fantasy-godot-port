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
	var a = get_node("Fighter")
	var c = get_node("Thief")
	var b = get_node("BlackBelt")
	PartyManager.add_party_member(m)
	PartyManager.add_party_member(a)
	PartyManager.add_party_member(c)
	PartyManager.add_party_member(b)


# remaining builtins e.g. _process, _input


# public methods


# private methods


# subclasses

