# @tool
# class_name name
extends Control
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars
@onready var inventory_gui: HFlowContainer = $InventoryPanel/InventoryGui


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
## gui inventory getter
func get_gui_inventory() -> HFlowContainer:
	return inventory_gui


# private methods


# subclasses
