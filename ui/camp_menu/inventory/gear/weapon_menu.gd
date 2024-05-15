# @tool
# class_name name
extends "res://ui/camp_menu/inventory/gear/gear_menu.gd"
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars
@onready var gil_label := $UpgradeInfoPanel/GilLabel as Label


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	gil_label.text = "Gil: %d" % PartyManager.gil


# remaining builtins e.g. _process, _input


# public methods


# private methods


# subclasses

