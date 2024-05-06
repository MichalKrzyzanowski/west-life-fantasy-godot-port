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
	PartyManager.add_member(m)
	PartyManager.add_member(a)
	PartyManager.add_member(c)
	PartyManager.add_member(b)
	var nodes = get_tree().get_nodes_in_group("persist")
	for node in nodes:
		print(node.name)


# remaining builtins e.g. _process, _input


# public methods


# private methods


# subclasses

